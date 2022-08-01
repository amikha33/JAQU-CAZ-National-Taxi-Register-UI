# frozen_string_literal: true

##
# Service used to add data to the session.
#
class SetLaRequestSession < BaseService
  # Initializer function.
  #
  # ==== Attributes
  # * +session+ - the user's session.
  # * +la_params+ - string, request parameters.
  # * +username+ - string, username.
  #
  def initialize(session:, la_params:, username:)
    @session = session
    @la_params = la_params
    @username = username
  end

  # Adds +la_request+ value to the session.
  def call
    session[:la_request] = {
      reference:, licensing_authorities:, name: la_params['name'], email: la_params['email'],
      details: la_params['details']
    }.stringify_keys!
  end

  private

  attr_reader :session, :la_params, :username

  # Call api to get the list of licensing authorities.
  def licensing_authorities
    AuthorityApi.licensing_authorities(username)
  end

  # Assigns a random reference value
  def reference
    SecureRandom.hex(10)
  end
end
