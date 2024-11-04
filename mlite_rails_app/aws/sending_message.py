import boto3
import json
import logging
from botocore.exceptions import ClientError

# Set up logging
logging.basicConfig(level=logging.INFO)

# Configure AWS settings
AWS_REGION = 'us-east-1'
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/209479273389/ml_training_requests.fifo'

# Create SQS client
sqs_client = boto3.client('sqs', region_name=AWS_REGION)

def send_training_request(training_parameters):
    """
    Send a training request message to the SQS queue.

    Args:
        training_parameters (dict): Parameters for the training request.

    Returns:
        None
    """
    message_body = {
        'training_params': training_parameters,
        'scheduled_time': '2023-10-31T10:00:00Z'  # Replace with actual time if needed
    }

    try:
        response = sqs_client.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message_body),
            MessageGroupId='training_requests'  # Required for FIFO queues
        )
        logging.info(f"Training request sent to SQS: {message_body}")
    except ClientError as e:
        logging.error(f"Failed to send message to SQS: {e}")

def process_messages():
    """
    Receive messages from the SQS queue and delete them after processing.

    Returns:
        None
    """
    try:
        response = sqs_client.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=10,  # Adjust the number of messages to retrieve
            WaitTimeSeconds=5  # Long polling
        )

        messages = response.get('Messages', [])
        for message in messages:
            logging.info(f"Received message: {message['Body']}")

            # Process the message here (e.g., parse the message body)

            # Delete the message after processing
            delete_message(message['ReceiptHandle'])
    except ClientError as e:
        logging.error(f"Failed to receive messages from SQS: {e}")

def delete_message(receipt_handle):
    """
    Delete a message from the SQS queue.

    Args:
        receipt_handle (str): The receipt handle of the message to delete.

    Returns:
        None
    """
    try:
        sqs_client.delete_message(
            QueueUrl=QUEUE_URL,
            ReceiptHandle=receipt_handle
        )
        logging.info(f"Deleted message with receipt handle: {receipt_handle}")
    except ClientError as e:
        logging.error(f"Failed to delete message: {e}")

# Call the function that you would like to use
# For example
if __name__ == '__main__':
    training_params = {'model_type': 'decision_tree', 'data_set_id': 123}
    send_training_request(training_params)
    process_messages()
