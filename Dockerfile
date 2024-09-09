# Use a common Ubuntu LTS base image
FROM ubuntu:20.04

# Set environment variables to avoid prompts during package installations

# Install Python, pip, and required system packages
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3-dev \
    build-essential \
    curl \
    wget \
    git \
    && apt-get clean

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install scikit-learn and PyTorch
RUN pip install torch torchvision torchaudio scikit-learn

# Set up a working directory
WORKDIR /app

RUN mkdir -p /app/src

CMD ["/bin/bash"]
