# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito.
module Cognito
  ##
  # Module used to manage the password change.
  module ForgotPassword
    ##
    # Class responsible for requesting a Cognito service to get rate limiting fields.
    #
    class GetUser < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      ##
      # Perform the call to Cognito service to get user attributes.
      def call
        admin_get_user
      end

      private

      # Variable used internally by the service.
      attr_reader :username

      # Perform the call to Cognito service to get user attributes.
      def admin_get_user
        client.admin_get_user({ user_pool_id:, username: })
      rescue AWS_ERROR::ServiceError => e
        log_error e
        raise Cognito::CallException.new('Something went wrong', forgot_password_error_path)
      end
    end
  end
end
