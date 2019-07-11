# frozen_string_literal: true

class ApplicationException < StandardError
  def response
    { errors: @errors }
  end
end
