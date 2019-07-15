# frozen_string_literal: true

class CsvUploadService < BaseService
  NAME_FORMAT = /^CAZ-([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))-([a-zA-Z]+)-\d+$/.freeze
  attr_reader :file, :errors

  def initialize(file:)
    @file = file
    @errors = nil
  end

  def call
    validate
    upload_to_s3
  end

  private

  def validate
    if no_file_selected? || invalid_extname? || invalid_filename?
      raise CsvUploadFailureException, errors
    end
  end

  def no_file_selected?
    if file.nil?
      @errors = 'Select a CSV'
    end
  end

  def invalid_extname?
    unless File.extname(file.original_filename).downcase == '.csv'
      @errors = 'The selected file must be a CSV'
    end
  end

  def invalid_filename?
    if File.basename(file.original_filename, '.*').match(NAME_FORMAT).nil?
      @errors = 'The selected file must be named correctly'
    end
  end

  def upload_to_s3
    s3_object = AMAZON_S3_CLIENT.bucket(bucket_name).object(file.original_filename)

    unless s3_object.upload_file(file)
      errors = 'The selected file could not be uploaded – try again'
      raise CsvUploadFailureException, errors
    end
    true
  end

  def bucket_name
    ENV['S3_AWS_BUCKET']
  end
end