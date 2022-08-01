# frozen_string_literal: true

##
# Sends an email to the DVLA with an LA request and sends an email confirmation to the LA.
#
class LaRequestDvlaMailer < SqsBase
  ##
  # Initializer function.
  #
  # * +session+ -
  #
  def initialize(session:)
    @reference = session.dig(:la_request, 'reference')
    @licensing_authorities = session.dig(:la_request, 'licensing_authorities')
    @name = session.dig(:la_request, 'name')
    @email = session.dig(:la_request, 'email')
    @details = session.dig(:la_request, 'details')
  end

  # Action sending an email to the DVLA.
  def call
    log_action('Sending DVLA message request to queue')
    send_message(dvla_message_body)
    log_action('Message sent successfully')
  rescue Aws::SQS::Errors::ServiceError => e
    log_error(e)
    false
  end

  private

  attr_reader :reference, :licensing_authorities, :name, :email, :details

  # Template id, dvla email address and parameters.
  def dvla_message_body
    {
      'templateId' => ENV.fetch('SQS_REQUEST_FORM_DVLA_TEMPLATE_ID', 'SQS_REQUEST_FORM_DVLA_TEMPLATE_ID'),
      'emailAddress' => dvla_email,
      'personalisation' => dvla_personalisation
    }.to_json
  end

  # Parameters which need it for email template.
  def dvla_personalisation
    { reference:, licensing_authorities:, name:, email:, details: }.to_json
  end
end
