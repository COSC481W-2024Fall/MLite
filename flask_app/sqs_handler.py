from __future__ import absolute_import
import boto3
import time
import json


import sys
import os

# Add the parent directory to sys.path
# primarily a python quirk -- may need to eventually create a parent directory runfile
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from src.ML.ML_API import MLAPI  


# AWS SQS Configuration
AWS_REGION = 'us-east-1'
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/209479273389/ml_training_requests.fifo'

# Initialize SQS client
sqs_client = boto3.client('sqs', region_name=AWS_REGION)

def poll_sqs():
    """
    Continuously polls the SQS queue for messages and processes them one by one.
    """
    print("Starting SQS polling...")

    while True:
        try:
            # Receive a single message from the SQS queue
            response = sqs_client.receive_message(
                QueueUrl=QUEUE_URL,
                MaxNumberOfMessages=1,  # Poll one message at a time
                WaitTimeSeconds=10      # Long polling (wait up to 10 seconds if no messages)
            )

            messages = response.get('Messages', [])
            if not messages:
                print("No messages in the queue. Waiting...")
                continue

            for message in messages:
                print(f"Received message: {message['Body']}")

                # Simulate model training
                process_message(message['Body'])

                # Delete the message after processing
                sqs_client.delete_message(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=message['ReceiptHandle']
                )
                print("Message processed and deleted from the queue.")

        except Exception as e:
            print(f"Error while polling SQS: {str(e)}")
            time.sleep(5)  # Wait before retrying


def process_message(message_body):
    """
    Simulate the processing of an SQS message (e.g., training a model).Brian 
    can put his code here
    """
    # Parse the message body (assuming JSON format)
    message = json.loads(message_body)
    job_name = message.get('job_name', 'unknown_job')
    dataset = message.get('dataset', 'unknown_dataset')

    print(f"Processing job: {job_name} with dataset: {dataset}")
    # Here, add your model training logic. For now, simulate training:
    api = MLAPI
    api.set_local_csv_dataset(dataset)
    if job_name == "recommend_model":
        api.recommed_model()
    if job_name == "logistic_regression":
        api.one_hot_encode()
        model = api.logistic_regression()
    if job_name == "decision_tree":
        api.one_hot_encode()
        model = api.decision_tree()
    if job_name == "linear_regression":
        api.one_hot_encode()
        model = api.linear_regression()
    if job_name == "svm":
        api.one_hot_encode()
        model = api.svm()


    print(f"Job {job_name} completed.")
    if model != None: return model
