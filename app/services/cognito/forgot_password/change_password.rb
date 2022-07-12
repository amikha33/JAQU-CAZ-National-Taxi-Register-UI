# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito.
module Cognito
  ##
  # Module used to manage the password change.
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
    #    Cognito::ForgotPassword::CompleteReset.call(
    #       username: 'user@example.com',
    #       password: 'password',
    #       password_confirmation: 'password'
    #    )
    #
    class ChangePassword < CognitoBaseService
      ##
      # Initializer method for the service. Used by class level method {call}[rdoc-ref:BaseService::call]
      #
      # ==== Attributes
      #
      # * +username+ - string, user email address
      # * +password+ - string, password submitted by the user
      # * +password_confirmation+ - string, password confirmation submitted by the user
      # * +token+ - string, JWT Token
      #
      def initialize(username:, password:, password_confirmation:, token:)
        @username = username
        @password = password
        @password_confirmation = password_confirmation
        @token = token
      end

      ##
      # Invokes the user params validation and perform call to AWS Cognito.
      #
      # Returns true if exception was not raised.
      def call
        validate_params
        perform_update_user_password_call
        reset_user_lockout_data
        reset_password_rate_limit
      end

      private

      # Variables used internally by the service.
      attr_reader :username, :password, :password_confirmation, :token

      # Validates user data.
      # Raise exception if validation failed.
      def validate_params
        username_from_token = Cognito::ForgotPassword::ValidateResetPasswordJwt.call(token:)
        form = ConfirmResetPasswordForm.new(password:, confirmation: password_confirmation)
        return if form.valid? && username_from_token == username

        log_invalid_params(form.message)
        raise CallException, form.message.to_json
      end

      # Perform call to AWS Cognito to set a new password.
      #
      # Raise exception if passwords not meet complexity of the criteria.
      def perform_update_user_password_call
        update_user_password
      rescue AWS_ERROR::UserNotFoundException
        raise CallException, 'Something went wrong'
      rescue AWS_ERROR::InvalidPasswordException, AWS_ERROR::InvalidParameterException => e
        log_error e
        raise CallException, I18n.t('password.errors.complexity')
      rescue AWS_ERROR::ServiceError => e
        log_error e
        raise CallException, 'Something went wrong'
      end

      # Perform call to AWS Cognito to set a new password.
      def update_user_password
        log_action('Confirming password reset')
        client.admin_set_user_password({
                                         user_pool_id:,
                                         username:,
                                         password:,
                                         permanent: true
                                       })
      end

      # Updates user data associated with account lockout.
      def reset_user_lockout_data
        Cognito::Lockout::UpdateUser.call(username:, failed_logins: 0)
      end

      # Updates user data associated with reset password rate limit and expires jwt token in cognito.
      def reset_password_rate_limit
        Cognito::ForgotPassword::UpdateUser.call(reset_counter: 1, username:)
      end
    end
  end
end
