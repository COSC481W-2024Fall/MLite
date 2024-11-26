import boto3
from flask import Flask, jsonify, request
from threading import Thread
from sqs_handler import poll_sqs
import requests
from dotenv import load_dotenv
import os
load_dotenv()


# Initialize Flask app
app = Flask(__name__)

# AWS SQS Configuration
AWS_REGION = 'us-east-1'
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/209479273389/ml_training_requests.fifo'

# Initialize SQS client
sqs_client = boto3.client('sqs', region_name=AWS_REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))

@app.route('/queue_job', methods=['POST'])
def queue_job():
    """
    API endpoint to add a job to the SQS queue.
    Expects a JSON payload with job details.
    """
    try:
        # Get job details from the request body
        job_data = request.json
        if not job_data:
            return jsonify({"error": "No job data provided"}), 400
        
        # Send job to SQS queue
        response = sqs_client.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=str(job_data)  # Convert the job data to a string
        )

        # Return success response
        return jsonify({
            "message": "Job added to queue",
            "job_id": response.get("MessageId")
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # Start SQS polling in a separate thread
    polling_thread = Thread(target=poll_sqs, daemon=True)
    polling_thread.start()

    # Start Flask server
    app.run(debug=True)



    
