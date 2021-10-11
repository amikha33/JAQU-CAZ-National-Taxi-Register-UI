# frozen_string_literal: true

##
# This class is used to authorize a user account and to sign uploaded CSV documents.
class User
  # required by Devise
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend Devise::Models

  # Allows to use validation callbacks.
  define_model_callbacks :validation
  # Allow remote authentication with devise.
  devise :remote_authenticatable
  # Takes care of verifying whether a user session has already expired or not.
  devise :timeoutable

  # Attribute that is being used to authorize a user and use it in csv uploading.
  attr_accessor :email, :username, :groups, :aws_status, :aws_session, :sub, :preferred_username,
                :confirmation_code, :hashed_password, :login_ip

  # Overrides default initializer for compliance with Devise Gem.
  def initialize(options = {})
    options.each do |key, value|
      public_send("#{key}=", value) if respond_to?(key)
    end
  end

  # Used in devise and should return nil when the object is not persisted.
  def to_key
    nil
  end

  # Returns a serialized hash of your object.
  #
  # ==== Example
  #   user = User.new
  #   user.email = 'example@email.com'
  #   user.groups = ['ntr.search.dev']
  #   user #<User email: example@email.com, username: nil, ...>
  #   user.serializable_hash #{:email=>"example@email.com", :username=>nil, ...}
  def serializable_hash(_options = nil) # rubocop:disable Metrics/MethodLength
    {
      email: email,
      username: username,
      groups: groups,
      aws_status: aws_status,
      aws_session: aws_session,
      sub: sub,
      preferred_username: preferred_username,
      hashed_password: hashed_password,
      login_ip: login_ip
    }
  end

  # Checks if the user belongs to 'ntr.search' group
  #
  # Returns boolean
  def search_group?
    groups.any? { |group| group.include?('ntr.search') }
  end
end
