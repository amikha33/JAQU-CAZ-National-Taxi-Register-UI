# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito.
module Cognito
  ##
  # Module used to manage the password change.
  module ForgotPassword
    ##
    # Class used for JWT validation.
    class ConfirmResetValidator < BaseService
      ##
      # Initializer method.
      #
      # ==== Attributes
      #
      # +session+ - user session
      # +params+ - query params
      #
      def initialize(session:, params:)
        @session = session
        @params = params
      end

      # Checks if token is in query or session, otherwise call exception.
      def call
        if params[:token].present?
          validate_token_from_query
        elsif session[:password_reset_token].present?
          validate_token_from_session
        else
          log_error 'There is no token inside query or session'
          raise Cognito::CallException.new('', invalid_or_expired_path)
        end
      end

      private

      attr_reader :session, :params

      # Validates token from query params and assigns hidden variables used by confirm_reset form.
      # Also assigns token into session.
      def validate_token_from_query
        username = Cognito::ForgotPassword::ValidateResetPasswordJwt.call(token: params[:token])
        session[:password_reset_token] = params[:token]
        [username, params[:token]]
      end

      # Validates token from session and assigns hidden variables used by confirm_reset form.
      def validate_token_from_session
        username = Cognito::ForgotPassword::ValidateResetPasswordJwt.call(token: session[:password_reset_token])
        [username, session[:password_reset_token]]
      end

      # Returns a string, eg. '/passwords/reset'.
      def invalid_or_expired_path
        Rails.application.routes.url_helpers.invalid_or_expired_passwords_path
      end
    end
  end
end
