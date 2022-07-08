# frozen_string_literal: true

##
# This is an abstract class used as a base for all mail classes.
class SqsBase < BaseService
  # Send SQS message.
  def send_message(message_body)
    return if Rails.env.development?

    AWS_SQS.send_message(
      queue_url: ENV.fetch('SQS_NOTIFY_QUEUE_NAME', ''),
      message_group_id: SecureRandom.uuid,
      message_body:,
      message_attributes: { 'contentType' => { string_value: 'application/json', data_type: 'String' } }
    )
  end

  private

  # Returns Support service email, eg. 'TaxiPHVDatabase.Support@informed.com'.
  def support_service_email
    Rails.configuration.x.support_service_email
  end
end
