# Use the pre-built Hunyuan3D image
FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Set working directory
WORKDIR /app

# Copy only the API server code
COPY api_server.py .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the API server
CMD ["python", "api_server.py"]
