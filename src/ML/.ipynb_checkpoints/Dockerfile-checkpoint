# Start from the NVIDIA PyTorch base image with CUDA support
FROM nvcr.io/nvidia/pytorch:23.03-py3

# Set the working directory
WORKDIR /app

# Copy the script to the container
COPY ML_API.py /app/ML_API.py

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
    numpy pandas scikit-learn jupyter

# Expose a port if needed for Jupyter or other web services
EXPOSE 8888

# Command to run the script with argparse support (modify as needed)
ENTRYPOINT ["python3", "/app/ML_API.py"]