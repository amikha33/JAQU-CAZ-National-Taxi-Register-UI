# frozen_string_literal: true

##
# Module used for jwt data encryption.
module JsonWebToken
  ##
  # Class used for encoding JWT.
  class Encode < BaseService
    ##
    # Initializer method.
    #
    # ==== Attributes
    #
    # * +payload+ - hashmap to be encrypted
    #
    def initialize(payload:)
      @payload = payload
    end

    ##
    # Encode payload using JWT gem.
    def call
      JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
    end

    private

    # Variable used internally by the service.
    attr_reader :payload
  end
end
