# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

# load support folder
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# stub connect to the AWS metadata server to get the AWS credentials.
Aws.config.update(stub_responses: true)

RSpec.configure do |config|
  # load request helpers
  [RequestSpecHelper, InjectSession, AddToSession].each { |h| config.include h, type: :request }

  # add helpers to rspec classes
  [UserFactory, MockHelper, UploadHelper, ActiveSupport::Testing::TimeHelpers].each { |h| config.include h }

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
