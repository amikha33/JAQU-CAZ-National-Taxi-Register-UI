# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito.
module Cognito
  ##
  # Module used to manage the password change.
  module ForgotPassword
    ##
    # Class used for JWT validation.
    class ValidateResetPasswordJwt < BaseService
      ##
      # Initializer method.
      #
      # ==== Attributes
      #
      # +token+ - JWT token
      #
      def initialize(token:)
        @token = token
      end

      ##
      # Validates jwt token with data stored in cognito.
      def call
        validate_token
        email_from_token
      end

      private

      # Variable used internally by the service.
      attr_reader :token

      # Token validation
      def validate_token
        return if (extract_attr('custom:pw-reset-requested') == pw_reset_from_token) && last_request_1_day_ago?

        log_error 'The token is invalid or has expired'
        raise Cognito::CallException.new('', invalid_or_expired_path)
      end

      # Checks if token has been generated 24 hours ago.
      def last_request_1_day_ago?
        reset_requested_integer = expiration_date_from_token.to_i
        last_request_date = DateTime.strptime(reset_requested_integer.to_s, '%s')
        last_request_date > DateTime.current
      end

      # Extract cognito attribute.
      def extract_attr(name)
        user_data.user_attributes.find { |attr| attr.name == name }&.value
      end

      # Email field stored in token.
      def email_from_token
        token_data['email']
      end

      # pw-reset-requested field stored in token.
      def pw_reset_from_token
        token_data['pw-reset-requested']
      end

      # exp fields stored in token.
      def expiration_date_from_token
        token_data['exp']
      end

      # Hashmap decoded from token.
      def token_data
        @token_data ||= JsonWebToken::Decode.call(token:)
      rescue JWT::DecodeError
        raise Cognito::CallException.new('', invalid_or_expired_path)
      end

      # Call to cognito to get user_data.
      def user_data
        unless defined? @user_data
          log_action('Query rate limiting fields from user account')
          @user_data = Cognito::ForgotPassword::GetUser.call(username: email_from_token)
        end

        @user_data
      rescue Cognito::CallException
        raise Cognito::CallException.new('', invalid_or_expired_path)
      end

      # Returns a string, eg. '/passwords/invalid_or_expired'.
      def invalid_or_expired_path
        Rails.application.routes.url_helpers.invalid_or_expired_passwords_path
      end
    end
  end
end
