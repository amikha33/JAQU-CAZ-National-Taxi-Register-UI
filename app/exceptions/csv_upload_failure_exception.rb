# frozen_string_literal: true

class CsvUploadFailureException < ApplicationException
  def initialize(errors = nil)
    @errors = errors
  end
end
