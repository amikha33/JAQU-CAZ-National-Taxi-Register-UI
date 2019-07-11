# frozen_string_literal: true

%w[AWS_REGION AWS_COGNITO_CLIENT_ID S3_AWS_ACCESS_KEY_ID S3_AWS_SECRET_ACCESS_KEY S3_AWS_REGION
   S3_AWS_BUCKET].each do |var|
  raise("You need to set #{var} variable in .env file.") if Dotenv::Railtie.load[var].blank?
end
