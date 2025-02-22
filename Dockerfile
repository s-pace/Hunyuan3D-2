# Use NVIDIA CUDA base image with Python support
FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Set up Python environment
ENV PYTHON_VERSION=3.11
# Add HuggingFace cache environment variable
ENV HF_HOME=/root/.cache/huggingface

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python${PYTHON_VERSION} \
    python3-pip \
    python${PYTHON_VERSION}-dev \
    libglib2.0-0 \
    libgl1 \
    libglu1-mesa \
    ffmpeg \
    libsm6 \
    libxext6 \
    libfontconfig1 \
    libxrender1 \
    # Ensure libGL.so.1 is installed
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN pip3 install opencv-contrib-python-headless -U opencv-python-headless -U opencv-python

# Pre-download the model during build
RUN python3 -c "from huggingface_hub import snapshot_download; snapshot_download('tencent/Hunyuan3D-2', local_dir='/root/.cache/hy3dgen/tencent/Hunyuan3D-2/hunyuan3d-dit-v2-0')"

# Copy application code
COPY . .

# Expose port 7860 for the Gradio app
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
