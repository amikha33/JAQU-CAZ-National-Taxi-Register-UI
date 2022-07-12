# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NtrUi
  # The class is responsible for building the middleware stack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # loads all files in folder
    config.autoload_paths << "#{config.root}/lib"
    # timeout the user session without activity.
    config.x.session_timeout_in_min = ENV.fetch('SESSION_TIMEOUT', 15).to_i
    config.x.feedback_url = ENV.fetch('FEEDBACK_URL', 'https://defragroup.eu.qualtrics.com/jfe/form/SV_2iugBKyyYVyl0LX')
    config.x.service_name = 'Taxi and PHV Data Portal'
    config.x.support_service_email = ENV.fetch('SUPPORT_SERVICE_EMAIL', 'TaxiPHVDatabase.Support@informed.com')
    config.x.version = File.read('.version')

    config.time_zone = 'London'
    config.x.time_format = '%d %B %Y %H:%M:%S %Z'

    # https://mattbrictson.com/dynamic-rails-error-pages
    config.exceptions_app = routes

    # https://stackoverflow.com/questions/49086693/how-do-i-remove-mail-html-content-from-rails-logs
    config.action_mailer.logger = nil

    # Configurable CSV upload size limit
    config.x.csv_file_size_limit = ENV.fetch('CSV_FILE_SIZE_LIMIT_MB', 50).to_i

    # Configurable host of the application
    config.x.host = ENV.fetch('HOST', '')
  end
end
