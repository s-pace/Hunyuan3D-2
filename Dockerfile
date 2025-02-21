# Use the pre-built Hunyuan3D image
FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy only the API server code
COPY api_server.py .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the API server with conda environment
CMD ["python", "api_server.py"]
