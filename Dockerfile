# Use NVIDIA CUDA base image
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3.10-dev \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch with CUDA support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Copy application code
COPY . .

# Build and install custom rasterizer
RUN cd hy3dgen/texgen/custom_rasterizer && \
    python3 setup.py install && \
    cd ../../..

# Build and install differentiable renderer
RUN cd hy3dgen/texgen/differentiable_renderer && \
    python3 setup.py install && \
    cd ../../..

# Expose port for API server
EXPOSE 8080

# Default command to run API server
CMD ["python3", "api_server.py", "--host", "0.0.0.0", "--port", "8080"]
