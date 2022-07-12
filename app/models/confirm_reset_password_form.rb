# frozen_string_literal: true

##
# This class is used to validate user data filled in +app/views/passwords/confirm_reset.html.haml+.
class ConfirmResetPasswordForm < BaseForm
  # Submitted password
  attr_reader :password
  # Submitted password confirmation
  attr_reader :confirmation

  # Regex which validates password to include one uppercase letter, digit, and has minimum 8 characters
  PASSWORD_REGEX = /\A(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\d\W])).{8,}\z/

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +password+ - string, eg. 'password'
  # * +confirmation+ - string, eg. 'password'
  def initialize(password:, confirmation:)
    @password = password
    @confirmation = confirmation
  end

  ##
  # Validate user data.
  #
  # Returns a boolean.
  def valid?
    @message = {}
    password_exist?
    correct_password_complexity? unless password.empty?
    correct_password_confirmation? unless password.empty?
    password_confirmation_exist?
    @message.empty?
  end

  private

  # Checks if password is present
  def password_exist?
    return true if password.present?

    @message[:password] = I18n.t('password.errors.password_required')
    false
  end

  # Checks if password has correct complexity
  def correct_password_complexity?
    return true if password.match(PASSWORD_REGEX)

    @message[:password] = I18n.t('password.errors.complexity')
    false
  end

  # Checks if password_confirmation is present
  def password_confirmation_exist?
    return true if confirmation.present?

    @message[:password_confirmation] = I18n.t('password.errors.password_confirmation_required')
    false
  end

  # Checks if +password+ and +confirmation+ password are same.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def correct_password_confirmation?
    return true if password == confirmation

    @message[:password] = I18n.t('password.errors.password_equality')
    @message[:password_confirmation] = I18n.t('password.errors.password_equality')
    false
  end
end
