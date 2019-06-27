# frozen_string_literal: true

module Devise
  module Strategies
    class RemoteAuthenticatable < Authenticatable
      # For an example check:
      # https://github.com/plataformatec/devise/blob/master/lib/devise/strategies/database_authenticatable.rb
      # Method called by warden to authenticate a resource.
      def authenticate!
        # authentication_hash doesn't include the password
        auth_params = authentication_hash
        auth_params[:password] = password

        # mapping.to is a wrapper over the resource model
        resource = mapping.to.new

        return fail! unless resource

        # remote_authentication method is defined in Devise::Models::RemoteAuthenticatable
        #
        # validate is a method defined in Devise::Strategies::Authenticatable. It takes
        # a block which must return a boolean value.
        #
        # If the block returns true the resource will be logged in
        # If the block returns false the authentication will fail!
        #
        # resource = resource.remote_authentication(auth_params)
        if validate(resource) { resource = resource.remote_authentication(auth_params) }
          resource.email = auth_params[:email]
          success!(resource)
        else
          fail!
        end
      end
    end
  end
end
