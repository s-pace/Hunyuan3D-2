# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install torch
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

# Copy requirements file
COPY requirements.txt .

# Expose the port Gradio runs on (typically 7860)
EXPOSE 8000

# Command to run the Gradio app
CMD ["python", "gradio_app.py"]
