from flask import Flask, request, jsonify
import joblib
import torch
import boto3
import os
from dotenv import load_dotenv

app = Flask(__name__)

# Load environment variables from .env file
load_dotenv()

# Global variables for model and type
model = None
model_type = None  # e.g., 'pytorch', 'tensorflow', 'scikit-learn'

# AWS S3 configuration
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")
S3_REGION_NAME = os.getenv("S3_REGION_NAME")
aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")

# Initialize S3 client
s3_client = boto3.client(
    's3',
    region_name=S3_REGION_NAME,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key
)

# Helper function to download the model from S3
def download_model_from_s3(model_filename):
    model_path = os.path.join('/tmp', model_filename)
    s3_client.download_file(S3_BUCKET_NAME, model_filename, model_path)
    return model_path

# Loading functions for each model type
def load_pytorch_model(model_path):
    model = torch.load(model_path)
    model.eval()  # Set model to evaluation mode
    return model

def load_sklearn_model(model_path):
    return joblib.load(model_path)

# Route to set the model
@app.route('/set_model', methods=['POST'])
def set_model():
    global model, model_type
    data = request.json
    model_filename = data.get("model_filename")

    if not model_filename:
        return jsonify({"error": "No model filename provided"}), 400

    try:
        model_path = download_model_from_s3(model_filename)

        # Determine model type by file extension and load accordingly
        if model_filename.endswith('.pt') or model_filename.endswith('.pth'):
            model = load_pytorch_model(model_path)
            model_type = 'pytorch'
        elif model_filename.endswith('.pkl'):
            model = load_sklearn_model(model_path)
            model_type = 'scikit-learn'
        else:
            return jsonify({"error": "Unsupported model format"}), 400

        return jsonify({"message": "Model loaded successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Preprocessing function for different models
def preprocess_input(inputs, model_type):
    if model_type == 'pytorch':
        return torch.tensor(inputs, dtype=torch.float32)
    else:
        return inputs  # For scikit-learn models, inputs are used directly

# Route for inference
@app.route('/inference', methods=['GET'])
def inference():
    global model, model_type
    model_input = request.args.get('model_input')

    if not model:
        return jsonify({"error": "Model not loaded"}), 400

    if model_input:
        try:
            inputs = eval(model_input)
            if not isinstance(inputs, list):
                return jsonify({"error": "model_input must be a list"}), 400

            # Preprocess input
            processed_input = preprocess_input(inputs, model_type)

            # Run inference based on model type
            if model_type == 'pytorch':
                with torch.no_grad():
                    prediction = model(processed_input).tolist()
            elif model_type == 'scikit-learn':
                prediction = model.predict([processed_input]).tolist()
            else:
                return jsonify({"error": "Unsupported model type for inference"}), 400

            return jsonify({"result": prediction})
        except (SyntaxError, NameError):
            return jsonify({"error": "Invalid format for model_input"}), 400
    else:
        return jsonify({"error": "model_input parameter is required"}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
