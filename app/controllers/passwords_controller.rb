# frozen_string_literal: true

##
# Controller class for the password change.
#
class PasswordsController < ApplicationController
  # checks if a user is logged in
  before_action :authenticate_user!, only: %i[new create]
  # checks if a user has a 'FORCE_NEW_PASSWORD' status
  before_action :validate_aws_status, only: %i[new create]
  # checks if a user aws session not expired
  before_action :validate_aws_session, only: %i[new create]
  # prevent browser page caching
  before_action :prevent_browser_caching,
                only: %i[submit_reset_your_password confirm_reset change]

  ##
  # Renders the password change page.
  #
  # ==== Path
  #
  #    GET /passwords/new
  #
  def new
    # renders view for initial password change
  end

  ##
  # Sets a new password when user sign in for the first time.
  #
  # ==== Path
  #
  #    :POST /passwords/create
  #
  def create
    respond_to_auth
  rescue Cognito::CallException => e
    sign_out current_user
    redirect_to new_user_session_path, alert: e.message
  rescue NewPasswordException => e
    @error = e.error_object
    render :new
  end

  ##
  # Renders the password change success page.
  #
  # ==== Path
  #
  #    :POST /passwords/success
  #
  def success
    # change actions success page
  end

  ##
  # Renders the reset page.
  #
  # ==== Path
  #
  #    :GET /passwords/reset
  #
  def reset
    # Renders static page
  end

  ##
  # Renders the email send page.
  #
  # ==== Path
  #
  #    :GET /passwords/email_send
  #
  def email_send
    # Renders static page
  end

  ##
  # Renders the invalid or expired page.
  #
  # ==== Path
  #
  #    :GET /passwords/invalid_or_expired
  #
  def invalid_or_expired
    # Renders static page
  end

  ##
  # Validates email address and sends email with jwt token.
  #
  # ==== Path
  #
  #    :POST /passwords/submit_reset_your_password
  #
  # ==== Params
  # * +username+ - user email address, eg 'email@example.com'
  #
  # ==== Exceptions
  # Any exception raised during {API call}[rdoc-ref:Cognito::ForgotPassword.call]
  # redirects to the {password reset page}[rdoc-ref:PasswordsController.reset]
  #
  def submit_reset_your_password
    Cognito::ForgotPassword::InitiateReset.call(username:)
    redirect_to email_send_passwords_path
  rescue Cognito::CallException => e
    redirect_to e.path, alert: (e.message.presence ? e.message : nil)
  end

  ##
  # Renders the confirm_reset page.
  #
  # ==== Path
  #
  #    :GET /passwords/confirm_reset
  #
  def confirm_reset
    @username, @token = Cognito::ForgotPassword::ConfirmResetValidator.call(params:, session:)
  rescue Cognito::CallException => e
    redirect_to e.path, alert: (e.message.presence ? e.message : nil)
  end

  ##
  # Sets provided new password and +reset_counter+ to 1 in Cognito.
  #
  # ==== Path
  #
  #    :POST /passwords/change
  #
  # ==== Params
  # * +username+ - string, user email address
  # * +password+ - string, password submitted by the user
  # * +password_confirmation+ - string, password confirmation submitted by the user
  #
  # ==== Exceptions
  # Any exception raised during {API call}[rdoc-ref:Cognito::ForgotPassword::Confirm.call]
  # redirects to the {password reset page}[rdoc-ref:PasswordsController.confirm_reset]
  #
  def change
    Cognito::ForgotPassword::ChangePassword.call(username:, password:, password_confirmation:, token:)
    clean_reset_password_session
    redirect_to success_passwords_path
  rescue Cognito::CallException => e
    redirect_to confirm_reset_passwords_path, alert: parse_alerts(e.message)
  end

  private

  # Parse alerts to hash if valid json, otherwise return string
  # When messages are empty return nil
  def parse_alerts(messages)
    return if messages.empty?

    JSON.parse(messages)
  rescue JSON::ParserError
    messages
  end

  # Prevents browser page caching in rails
  def prevent_browser_caching
    # https://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  # Sets a new password when user sign in for the first time.
  def respond_to_auth
    Cognito::RespondToAuthChallenge.call(
      user: current_user, password:, confirmation: password_confirmation
    )
    update_session_data
    redirect_to success_passwords_path
  end

  # Updates user session data with a new response from Cognito.
  def update_session_data
    session['warden.user.user.key'] = [current_user.serializable_hash.transform_keys(&:to_s), nil]
  end

  # Checks if user +aws_status+ equality to 'FORCE_NEW_PASSWORD'.
  def validate_aws_status
    return if current_user.aws_status == 'FORCE_NEW_PASSWORD'

    redirect_to root_path
  end

  # Checks if user +aws_session+ is present. If not sign out user and redirect to sign in page.
  def validate_aws_session
    return if current_user.aws_session

    sign_out current_user
    redirect_to new_user_session_path, alert: I18n.t('expired_session')
  end

  # Returns the list of permitted params
  def password_params
    params.require(:user).permit(:password, :password_confirmation, :username, :token)
  end

  # Returns a string
  def token
    password_params[:token]
  end

  # Returns a string
  def password
    password_params[:password]
  end

  # Returns a string
  def password_confirmation
    password_params[:password_confirmation]
  end

  # Returns a string
  def username
    password_params[:username]&.downcase
  end

  # Clears user session
  def clean_reset_password_session
    session[:password_reset_token] = nil
  end
end
