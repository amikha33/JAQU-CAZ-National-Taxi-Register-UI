# frozen_string_literal: true

##
# Sends an email to the user with reset password link.
#
class ResetPasswordMailer < SqsBase
  include Rails.application.routes.url_helpers
  ##
  # Initializer function.
  #
  # * +email+ - string, user email address.
  # * +jwt_token+ - string, jwt token.
  #
  def initialize(email:, jwt_token:)
    @email = email
    @jwt_token = jwt_token
  end

  # Action sending an email to the user.
  def call
    log_action('Create send message request to queue')
    send_message(message_body)
    log_action('Message sent successfully')
  rescue Aws::SQS::Errors::ServiceError => e
    log_error(e)
    false
  end

  private

  attr_reader :email, :jwt_token

  # Template id, users email address and parameters.
  def message_body
    {
      'templateId' => ENV.fetch('SQS_RESET_PASSWORD_TEMPLATE_ID', 'SQS_RESET_PASSWORD_TEMPLATE_ID'),
      'emailAddress' => email,
      'personalisation' => personalisation,
      'reference' => SecureRandom.uuid
    }.to_json
  end

  # Parameters which need it for email template.
  def personalisation
    { link: "https://#{link_host}#{link_path}" }.to_json
  end

  # Enviroment host name.
  def link_host
    Rails.configuration.x.host.split(',')[0]
  end

  # Link path with jwt token.
  def link_path
    confirm_reset_passwords_path(token: jwt_token)
  end
end
