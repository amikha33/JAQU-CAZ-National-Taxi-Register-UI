# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the password change
  module ForgotPassword
    ##
    # Class responsible for the second step of the password recovery process using
    # {ConfirmForgotPassword}[https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_ConfirmForgotPassword.html].
    # Sets provided new password in Cognito.
    #
    # It requires Cognito::ForgotPassword to be called first
    # as the user needs to submit the code sent in the previous step.
    #
    # ==== Usage
    #
    #    Cognito::ForgotPassword::Confirm.call(
    #       username: 'user@example.com',
    #       code: '123456',
    #       password: 'password',
    #       password_confirmation: 'password'
    #    )
    #
    class Confirm < CognitoBaseService
      ##
      # Initializer method for the service. Used by class level method {call}[rdoc-ref:BaseService::call]
      #
      # ==== Attributes
      # * +username+ - string, user email address
      # * +password+ - string, password submitted by the user
      # * +password_confirmation+ - string, password confirmation submitted by the user
      # * +code+ - 6 digit string of numbers, code sent to user
      def initialize(username:, password:, code:, password_confirmation:)
        @username = username
        @password = password
        @password_confirmation = password_confirmation
        @code = code
      end

      ##
      # Invokes the user params validation and perform call to AWS Cognito.
      #
      # Returns true if exception was not raised.
      def call
        validate_params
        perform_cognito_call
        true
      end

      private

      # Variables used internally by the service
      attr_reader :username, :password, :code, :password_confirmation

      # Validates user data.
      # Raise exception if validation failed.
      def validate_params
        form = ConfirmResetPasswordForm.new(
          password:,
          confirmation: password_confirmation,
          code:
        )
        return if form.valid?

        log_invalid_params(form.message)
        raise CallException, form.message
      end

      # Perform call to AWS Cognito to set a new password.
      #
      # Raise exception if confirmation code does not match, expired or passwords not meet
      # complexity of the criteria.
      def perform_cognito_call
        confirm_forgot_password
      rescue AWS_ERROR::CodeMismatchException, AWS_ERROR::ExpiredCodeException,
             AWS_ERROR::UserNotFoundException
        raise CallException, I18n.t('password.errors.code_mismatch')
      rescue AWS_ERROR::InvalidPasswordException, AWS_ERROR::InvalidParameterException => e
        log_error e
        raise CallException, I18n.t('password.errors.complexity')
      rescue AWS_ERROR::ServiceError => e
        log_error e
        raise CallException, 'Something went wrong'
      end

      # Perform call to AWS Cognito to set a new password.
      def confirm_forgot_password
        log_action('Confirming forgot password')
        client.confirm_forgot_password(
          client_id: ENV.fetch('AWS_COGNITO_CLIENT_ID', nil),
          username:,
          password:,
          confirmation_code: code
        )
      end
    end
  end
end
