# Use the pre-built Hunyuan3D image
FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Set working directory
WORKDIR /app

# Install system dependencies required for pymeshlab
RUN apt-get update && apt-get install -y \
    libglu1-mesa-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Add conda to path
ENV PATH="/opt/conda/bin:${PATH}"

# Install pymeshlab using conda
RUN conda install -c conda-forge pymeshlab -y

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy only the API server code
COPY api_server.py .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the API server
CMD ["python", "api_server.py"]
