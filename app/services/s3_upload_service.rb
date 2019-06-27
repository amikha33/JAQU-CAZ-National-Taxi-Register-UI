# frozen_string_literal: true

class S3UploadService < BaseService
  attr_reader :file

  def initialize(file:)
    @file = file
  end

  def call
    s3_object = s3_instance.bucket(bucket_name).object(file_key)
    s3_object.upload_file(file)
  end

  private

  def s3_instance
    Aws::S3::Resource.new
  end

  def bucket_name
    ENV['AWS_BUCKET']
  end

  def file_key
    "new_file_#{Time.current.to_i}"
  end
end
