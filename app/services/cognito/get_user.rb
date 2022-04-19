# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Class responsible for getting actual user data from Cognito.
  #
  class GetUser < CognitoBaseService
    # Variables used internally by the service
    attr_reader :access_token, :user, :username

    ##
    # Initializer method for the service.
    #
    # ==== Attributes
    # * +access_token+ - UUID , eg. '8d414417-2bbe-4e70-a145-e108f45d33d3'
    # * +user+ - instance of {User class}[rdoc-ref:User]
    # * +username+ - string, user email address
    def initialize(access_token:, username:, user: User.new)
      @access_token = access_token
      @user = user
      @username = username&.downcase
    end

    ##
    # Sets the details of current user using Cognito response.
    def call
      update_user
      user
    end

    private

    # Sets the details of current user using Cognito response.
    def update_user # rubocop:disable Metrics/AbcSize
      user.username = user_data.username
      user.email = extract_attr('email')
      user.sub = extract_attr('sub')
      user.aws_status = 'OK'
      user.preferred_username = preferred_username || sub
      update_preferred_username
    end

    # Returns a string, eg. `test@example.com`
    def extract_attr(name)
      user_data.user_attributes.find { |attr| attr.name == name }&.value
    end

    # Returns instance of OpenStruct which is contains:
    # * +username+ - string, username, eg. 'test'
    # * +email+ - string, user email address, eg. 'test@example.com'
    # * +preferred_username+ - UUID, eg '685f6373-75bc-4cb9-9a01-dbe1f9c383cf'
    def user_data
      unless defined? @user_data
        log_action('Getting user')
        @user_data = client.get_user(access_token:)
      end

      @user_data
    end

    # Requesting a Cognito service to update `preferred_username` attribute
    def update_preferred_username
      Cognito::UpdatePreferredUsername.call(
        username:,
        preferred_username:,
        sub:
      )
    end

    # `preferred_username` on Cognito
    def preferred_username
      @preferred_username ||= extract_attr('preferred_username')
    end

    # `sub` on Cognito
    def sub
      @sub ||= extract_attr('sub')
    end
  end
end
