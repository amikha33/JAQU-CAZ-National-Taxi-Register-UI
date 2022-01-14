# frozen_string_literal: true

# Custom constraint which returns true if a request should be given access to a route, or false
# if the request should be rejected. Used in routes.rb
class CheckRequestFormat
  def self.matches?(request)
    %i[html json xml].include?(request.format.symbol)
  end
end
