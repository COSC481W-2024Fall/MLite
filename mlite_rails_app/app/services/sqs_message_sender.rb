class SqsMessageSender
  def self.send_training_request(training_parameters)
    queue_url = ENV['AWS_SQS_QUEUE_URL']

    message_body = {
      training_params: training_parameters,
      scheduled_time: Time.now.iso8601
    }.to_json

    begin
      SQS_CLIENT.send_message({
                                queue_url: queue_url,
                                message_body: message_body,
                                message_group_id: 'training_requests'
                              })

      Rails.logger.info("Training request sent to SQS: #{message_body}")
    rescue Aws::SQS::Errors::ServiceError => e
      Rails.logger.error("Failed to send message to SQS: #{e.message}")
    end
  end
end