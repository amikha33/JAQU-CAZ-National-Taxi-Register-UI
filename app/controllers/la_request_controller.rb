# frozen_string_literal: true

##
# Controller class for the LA Request pages
#
class LaRequestController < ApplicationController
  # Checks if a user is logged in
  before_action :authenticate_user!
  # Checks whether session values is populated
  before_action :check_session_data, only: %i[review]

  ##
  # Renders the LA request form page.
  #
  # ==== Path
  #    GET /la_request
  #
  def index
    # renders the LA request form page.
  end

  ##
  # Submits the LA request form
  #
  # ==== Path
  #    POST /la_request
  #
  def submit_la_request
    form = LaRequestForm.new(la_params)
    SetLaRequestSession.call(session:, la_params:, username: @current_user.preferred_username)
    if form.valid?
      redirect_to review_la_request_index_path
    else
      @errors = form.errors
      render :index
    end
  end

  ##
  # Renders the review LA request page.
  #
  # ==== Path
  #    GET /la_request/review
  #
  def review
    # renders the review LA request page.
  end

  ##
  # Submits the LA request form confirmation
  #
  # ==== Path
  #    POST /la_request/review
  #
  def submit_review
    LaRequestDvlaMailer.call(session:)
    LaRequestLaMailer.call(session:)
    flash[:success] = I18n.t('la_request_form.success')
    redirect_to authenticated_root_path
  end

  private

  # Returns the list of permitted params
  def la_params
    params.require(:la_request_form).permit(:name, :email, :details)
  end

  # Checks if request form data is present in the session.
  def check_session_data
    return if session[:la_request]

    Rails.logger.info('Request form data is missing in the session. Redirecting to start page.')
    redirect_to la_request_index_path
  end
end
