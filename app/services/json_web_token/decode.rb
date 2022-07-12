# frozen_string_literal: true

##
# Module used for jwt data encryption.
module JsonWebToken
  ##
  # Class used for decoding JWT.
  class Decode < BaseService
    ##
    # Initializer method.
    #
    # ==== Attributes
    #
    # * +token+ - JWT token
    #
    def initialize(token:)
      @token = token
    end

    ##
    # Decode token using JWT gem.
    def call
      JWT.decode(token, Rails.application.secrets.secret_key_base.to_s).first
    end

    private

    # Variable used internally by the service.
    attr_reader :token
  end
end
