# frozen_string_literal: true

class UploadController < ApplicationController
  before_action :authenticate_user!

  def index
    # No variables or interactions on root page
  end
end
