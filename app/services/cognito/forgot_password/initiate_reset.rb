# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito.
module Cognito
  ##
  # Module used to manage the password change.
  module ForgotPassword
    ##
    # Class responsible for requesting a Cognito service to perform email send with a new
    # temporary password.
    #
    class InitiateReset < CognitoBaseService
      # Variable used internally by the service.
      attr_reader :username

      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      #
      # * +username+ - string, user email address
      #
      def initialize(username:)
        @username = username&.downcase
      end

      ##
      # Invokes the user params validation, checks reset password rate limit and sends message to AWS SQS.
      def call
        validate_params
        rate_limit_verification
        ResetPasswordMailer.call(email: username, jwt_token: create_jwt_token)
      end

      private

      # Validates user data.
      # Raise exception if validation failed.
      def validate_params
        form = ResetPasswordForm.new(username)
        return if form.valid?

        log_invalid_params(form.message)
        raise CallException.new(form.message, error_path)
      end

      # Checks the password reset rate limit and update it
      # In case if reset counter is over 5 and last request was made less than 1h ago, user
      # redirects to the next page but without sending any email at all
      # returns value of pw_reset_requested cognito field.
      def rate_limit_verification
        Cognito::ForgotPassword::RateLimitVerification.call(username:, current_date_time:)
      end

      # Creates JWT Token.
      def create_jwt_token
        Cognito::ForgotPassword::CreateResetPasswordJwt.call(username:, current_date_time:)
      end

      # Returns current date time, used as 'custom:pw-reset-requested' cognito field.
      def current_date_time
        @current_date_time ||= DateTime.current.to_i
      end

      # Returns a string, eg. '/passwords/reset'.
      def error_path
        Rails.application.routes.url_helpers.reset_passwords_path
      end
    end
  end
end
