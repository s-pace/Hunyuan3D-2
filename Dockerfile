# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Install PyTorch with CUDA support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Copy the application code
COPY . .

# Set environment variable for NVIDIA GPUs
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Copy only the API server code
COPY api_server.py .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the API server with conda environment
CMD ["python", "api_server.py"]
