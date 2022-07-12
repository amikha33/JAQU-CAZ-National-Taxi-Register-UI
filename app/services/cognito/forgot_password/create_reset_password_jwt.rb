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
    class CreateResetPasswordJwt < BaseService
      ##
      # Initializer method.
      #
      # ==== Attributes
      #
      # +username+ - user email
      # +current_date_time+ - date stored in cognito 'pw-reset-requested' field
      #
      def initialize(username:, current_date_time:)
        @username = username
        @current_date_time = current_date_time
      end

      # Encode reset password payload data as JWT.
      def call
        JsonWebToken::Encode.call(payload: { 'pw-reset-requested' => current_date_time,
                                             'email' => username,
                                             'exp' => (DateTime.current + 1.day).to_i })
      end

      private

      # Variable used internally by the service.
      attr_reader :username, :current_date_time
    end
  end
end
