from __future__ import absolute_import
import boto3
import time
import json
import os
import requests
from sklearn.linear_model import LogisticRegression, LinearRegression
import pickle

import sys
import os

# Add the parent directory to sys.path
# primarily a python quirk -- may need to eventually create a parent directory runfile
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
# from src.ML.ML_API import MLAPI
from ML_API import MLAPI

# AWS SQS Configuration
AWS_REGION = 'us-east-1'
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/209479273389/ml_training_requests.fifo'

def download_file_from_s3(bucket_name, key, download_path):
    s3_client = boto3.client('s3', region_name=AWS_REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
    try:
        s3_client.download_file(bucket_name, key, download_path)
    except Exception as e:
        print(f"Error downloading or using the file: {str(e)}")

def upload_file_to_rails(model_id, file_path):
    RAILS_APP_HOST=os.getenv("RAILS_APP_HOST")
    RAILS_APP_PORT=os.getenv("RAILS_APP_PORT")
    auth_token = os.getenv("UPLOAD_AUTH_TOKEN")
    rails_url = f"{'http://localhost' if RAILS_APP_HOST == 'localhost' or not RAILS_APP_HOST else RAILS_APP_HOST}{f':{RAILS_APP_PORT}' if RAILS_APP_PORT else ''}/models/{model_id}/upload_file?auth_token={auth_token}"

    try:
        with open(file_path, 'rb') as file:
            files = {'file': file}
            response = requests.post(rails_url, files=files)

        if response.status_code == 200:
            {"message": "File uploaded successfully", "response": response.json()}
        else:
            {"error": "Failed to upload file", "details": response.json()}, response.status_code

    except Exception as e:
        {"error": "Something went wrong", "details": str(e)}, 500

def train_model(model_type, hyperparams, label):
    api = MLAPI()
    api.set_local_csv_dataset(dataset='dataset.csv')
    if model_type == "logistic_regression":
        # api.one_hot_encode()
        model = api.logistic_regression(label=label)
    if model_type == "decision_tree":
        # api.one_hot_encode()
        model = api.decision_tree(label=label)
    if model_type == "linear_regression":
        # api.one_hot_encode()
        model = api.linear_regression(label=label)
    if model_type == "svm":
        # api.one_hot_encode()
        model = api.svm(label=label)
    return model

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
    message = json.loads(message_body)
    
    model_id = message['training_params']['model']['id']
    model_type = message['training_params']['model']['model_type']
    hyperparams = message['training_params']['model']['hyperparams']
    label = message['training_params']['model']['labels'][0]
    dataset_s3_key = message['training_params']['dataset_s3_key']

    print(f"Processing job: {model_id} with dataset: {dataset_s3_key}")
    download_file_from_s3(os.environ.get('AWS_S3_BUCKET'), dataset_s3_key, 'dataset.csv')
    model = train_model(model_type, hyperparams, label)
    # model = LinearRegression() # hardcode model for now
    with open('model.pkl', 'wb') as file:
        pickle.dump(model, file)
    upload_file_to_rails(model_id, 'model.pkl')
    print(f"Job {model_id} completed.")
