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

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install PyTorch and CUDA first (with specific version)
RUN pip3 install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121

# Install pytorch3d
RUN pip3 install pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py310_cu121_pyt210/download.html

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
EXPOSE 8000

# Default command to run API server
CMD ["python3", "api_server.py", "--host", "0.0.0.0", "--port", "8000"]
