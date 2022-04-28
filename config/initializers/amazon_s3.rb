# frozen_string_literal: true

is_running_locally = Rails.env.development?
is_running_on_aws = Rails.env.production? && ENV.fetch('BUILD_ID', nil)

# Development environment config
access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID', nil)
secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
assume_role_arn = ENV.fetch('AWS_ROLE_ARN', nil)
assume_role_session_name = 'jaqu-lowerDeveloperRole-localdev'

# Production environment config
task_metadata_address = '169.254.170.2'

# Common environment config
region = ENV.fetch('AWS_REGION', 'eu-west-2')

credentials = if is_running_locally
                # On local machines we are using STS
                Aws::AssumeRoleCredentials.new(
                  client: Aws::STS::Client.new(
                    region:,
                    access_key_id:,
                    secret_access_key:
                  ),
                  role_arn: assume_role_arn,
                  role_session_name: assume_role_session_name
                )
              elsif is_running_on_aws
                # On AWS ECS we are using task credentials
                Aws::ECSCredentials.new({ ip_address: task_metadata_address })
              else
                # In tests and Docker build we are using regular credentials
                Aws::Credentials.new(access_key_id, secret_access_key)
              end

AMAZON_S3_CLIENT = Aws::S3::Resource.new(
  region:,
  credentials:
)
