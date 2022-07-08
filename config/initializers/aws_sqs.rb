# frozen_string_literal: true

credentials = if ENV.fetch('AWS_ACCESS_KEY_ID', nil) && ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
                Aws::Credentials.new(
                  ENV.fetch('AWS_ACCESS_KEY_ID', 'AWS_ACCESS_KEY_ID'),
                  ENV.fetch('AWS_SECRET_ACCESS_KEY', 'AWS_SECRET_ACCESS_KEY')
                )
              else
                Aws::ECSCredentials.new({ ip_address: '169.254.170.2' })
              end
region = ENV.fetch('AWS_REGION', 'eu-west-1')

AWS_SQS = Aws::SQS::Client.new(region:, credentials:)
