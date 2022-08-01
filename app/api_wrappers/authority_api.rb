# frozen_string_literal: true

##
# This class wraps calls being made to the NTR backend API.
# The base URL for the calls is configured by +TAXI_PHV_REGISTER_API_URL+ environment variable.
#
# All calls have the correlation ID and JSON content type added to the header.
#
# All methods are on the class level, so there is no initializer method.
class AuthorityApi < BaseApi
  base_uri "#{API_URL}/v1/authority"

  headers(
    'Content-Type' => 'application/json',
    'Accept' => 'application/json',
    'X-Correlation-ID' => -> { SecureRandom.uuid }
  )

  class << self
    ##
    # Calls +/v1/authority/:authorised_uploader_id+ endpoint with +GET+ method
    # and returns the list of LA names where the user is an authorised uploader.
    #
    # ==== Attributes
    #
    # * +uploader_id+ - Current user's preferred username, eg. 'a68ec075-9359-44f4-a75e-68f2b1b01146'
    #
    # ==== Result
    #
    # Returned array:
    # * String, list of LA where the user is an authorised uploader, eg. ["Birmingham", "Leeds"]
    #
    def licensing_authorities(uploader_id)
      log_call('Getting licensing authority name')
      request(:get, "/#{uploader_id}")['licensingAuthoritiesNames']
    end
  end
end
