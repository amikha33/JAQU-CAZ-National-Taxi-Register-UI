# frozen_string_literal: true

##
# Sends an email an email confirmation to the LA.
#
class LaRequestLaMailer < SqsBase
  ##
  # Initializer function.
  #
  # * +session+ -
  #
  def initialize(session:)
    @reference = session.dig(:la_request, 'reference')
    @name = session.dig(:la_request, 'name')
    @email = session.dig(:la_request, 'email')
  end

  # Action sending an email to the LA.
  def call
    log_action('Sending LA message request to queue')
    send_message(la_message_body)
    log_action('Message sent successfully')
  rescue Aws::SQS::Errors::ServiceError => e
    log_error(e)
    false
  end

  private

  attr_reader :reference, :name, :email

  # Template id, la email address and parameters.
  def la_message_body
    {
      'templateId' => ENV.fetch('SQS_REQUEST_FORM_LA_TEMPLATE_ID', 'SQS_REQUEST_FORM_LA_TEMPLATE_ID'),
      'emailAddress' => email,
      'personalisation' => la_personalisation
    }.to_json
  end

  # Parameters which need it for email template.
  def la_personalisation
    { name:, reference: }.to_json
  end
end
