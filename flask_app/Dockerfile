# Dockerfile for Flask app inside `flask_app/`
FROM python:3.12-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the entire app directory
COPY . .

# Expose port 5000 and run the Flask app
EXPOSE 5002
CMD ["python", "app.py"]
