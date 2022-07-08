# frozen_string_literal: true

##
# Sends an email to the user with successful CSV upload confirmation.
#
class CsvUploadMailer < SqsBase
  ##
  # Initializer function.
  #
  # * +email+ - string, user email address.
  # * +job_data+ - hash, jobs data.
  #
  def initialize(email:, job_data:)
    @email = email
    @job_data = job_data
  end

  # Action sending an email to the user.
  def call
    log_action('Create send message request to queue')
    send_message(message_body)
    log_action('Message sent successfully')
  rescue Aws::SQS::Errors::ServiceError => e
    log_error(e)
    false
  end

  private

  attr_reader :email, :job_data

  # Template id, users email address and parameters.
  def message_body
    {
      'templateId' => ENV.fetch('SQS_CONFIRM_UPLOAD_EMAIL_TEMPLATE_ID', 'SQS_CONFIRM_UPLOAD_EMAIL_TEMPLATE_ID'),
      'emailAddress' => email,
      'personalisation' => personalisation
    }.to_json
  end

  # Parameters which need it for email template.
  def personalisation
    { file_name: job_data[:filename], submission_time: job_data[:submission_time], support_service_email: }.to_json
  end
end
