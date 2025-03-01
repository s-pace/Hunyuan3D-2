# Use NVIDIA CUDA base image with Python support
FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Set up Python environment
ENV PYTHON_VERSION=3.11

# Expose port 7860 for the application
EXPOSE 8000

# Run the application
CMD ["python", "hg_app.py"]
