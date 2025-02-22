FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Set Python version explicitly
ENV PYTHON_VERSION=3.11

# Install Python 3.11, pip, and OpenCV dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-distutils \
    curl \
    # OpenCV and GL dependencies
    nvidia-utils-525 \
    libnvidia-gl-525 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libglu1-mesa \
    ffmpeg \
    # Additional OpenGL dependencies
    libgl1 \
    libglvnd0 \
    libgl1-mesa-dri \
    libglx0 \
    libegl1 \
    # Add PyMeshLab specific dependencies
    libglu1 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Create a symbolic link for python and set Python 3.11 as default
RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python
RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3

# Verify Python version
RUN python --version

# Install torch with CUDA 11.8
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Copy requirements file
COPY requirements.txt .

# Install requirements
RUN pip3 install -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose port 8000
EXPOSE 8000

# Set environment variables for OpenGL
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics
ENV PYTHONPATH=/app
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Command to run the app
CMD ["python", "api_server.py"]
