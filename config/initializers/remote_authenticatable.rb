# frozen_string_literal: true

module Devise
  module Models
    module RemoteAuthenticatable
      extend ActiveSupport::Concern
      # Here you do the request to the external webservice
      #
      # If the authentication is successful you should return
      # a resource instance
      #
      # If the authentication fails you should return false
      def remote_authentication(params)
        client = Aws::CognitoIdentityProvider::Client.new

        begin
          response = client.initiate_auth(
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            auth_flow: 'USER_PASSWORD_AUTH',
            auth_parameters:
              {
                'USERNAME' => params[:username],
                'PASSWORD' => params[:password]
              }
          )

          if response
            user = User.new
            user.email = JSON.parse(response.challenge_parameters['userAttributes'])['email']
            user
          else
            false
          end
        rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
          #TODO: Log errors
          false
        rescue StandardError
          false
        end
      end

      module ClassMethods
        # Overridden methods from Devise::Models::Authenticatable
        #
        # This method is called from:
        # Warden::SessionSerializer in devise
        #
        # It takes as many params as elements had the array
        # returned in serialize_into_session
        #
        # Recreates a resource from session data
        #
        def serialize_from_session(data, _salt)
          resource = new
          resource.email = data['email']
          resource
        end

        #
        # Here you have to return and array with the data of your resource
        # that you want to serialize into the session
        #
        # You might want to include some authentication data
        #
        def serialize_into_session(record)
          [
            {
              email: record.email
            },
            nil
          ]
        end
      end
    end
  end
end
