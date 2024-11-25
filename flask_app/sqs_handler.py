from __future__ import absolute_import
import boto3
import time
import json
import os
import requests
from flask import jsonify


import sys
import os

# Add the parent directory to sys.path
# primarily a python quirk -- may need to eventually create a parent directory runfile
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from src.ML.ML_API import MLAPI


# AWS SQS Configuration
AWS_REGION = 'us-east-1'
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/209479273389/ml_training_requests.fifo'

def upload_file_to_rails(model_id, file_path):
    # The file to upload
    auth_token = os.getenv("UPLOAD_AUTH_TOKEN")
    rails_url = f"http://localhost:3000/models/{model_id}/upload_file?auth_token={auth_token}"

    try:
        # Open the file and send it in a POST request
        with open(file_path, 'rb') as file:
            files = {'file': file}
            response = requests.post(rails_url, files=files)

        # Handle the response from Rails
        if response.status_code == 200:
            return jsonify({"message": "File uploaded successfully", "response": response.json()})
        else:
            return jsonify({"error": "Failed to upload file", "details": response.json()}), response.status_code

    except Exception as e:
        return jsonify({"error": "Something went wrong", "details": str(e)}), 500

def poll_sqs():
    """
    Continuously polls the SQS queue for messages and processes them one by one.
    """
    print("Starting SQS polling...")
    # Initialize SQS client
    sqs_client = boto3.client('sqs', region_name=AWS_REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))

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
    model_id = message.get('id', 'unknown_model')

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


    time.sleep(5)  # Simulate training time

    upload_file_to_rails(model_id, 'temp.txt')

    print(f"Job {job_name} completed.")
    if model != None: return model
