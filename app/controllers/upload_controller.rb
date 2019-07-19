# frozen_string_literal: true

class UploadController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_new_password_path

  def import
    file_name = CsvUploadService.call(file: file, user: current_user)
    redirect_to processing_upload_index_path(file_name: file_name)
  end

  def processing; end

  def data_rules; end

  private

  def file
    params[:file]
  end

  def redirect_to_new_password_path
    if current_user.aws_status == 'FORCE_NEW_PASSWORD'
      redirect_to new_password_path
    end
  end
end
