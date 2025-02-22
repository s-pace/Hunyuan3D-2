# Use NVIDIA CUDA base image with Python support
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# Set up Python environment
ENV PYTHON_VERSION=3.11

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python${PYTHON_VERSION} \
    python3-pip \
    python${PYTHON_VERSION}-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libglu1-mesa \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copy application code
COPY . .

# Run the application
CMD ["python3", "api_server.py"]
