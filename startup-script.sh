#!/bin/bash

echo "🚀 Starting initialization script..."

# Create a log directory with proper permissions
mkdir -p /var/log/hunyuan3d
chmod 755 /var/log/hunyuan3d
echo "✅ Log directory created at /var/log/hunyuan3d"

# Install system dependencies
apt-get update && apt-get upgrade -y
echo "✅ System packages updated"

# Clone the repository if it doesn't exist
if [ ! -d "/root/Hunyuan3D-2" ]; then
    cd /root
    echo "📦 Cloning repository..."
    git clone https://github.com/s-pace/Hunyuan3D-2.git
fi

cd /root/Hunyuan3D-2

# Always ensure dependencies are up to date
echo "📦 Upgrading pip..."
python3 -m pip install --upgrade pip
echo "✅ Pip upgraded"

echo "📦 Installing/Updating Python dependencies..."
pip install -r requirements.txt || {
    echo "⚠️ Error during initial pip install, trying with --no-cache-dir..."
    pip install --no-cache-dir -r requirements.txt
}
echo "✅ Python dependencies installed"

# Install/Update texture dependencies
echo "📦 Installing/Updating texture rasterizer..."
cd hy3dgen/texgen/custom_rasterizer
python3 setup.py install
echo "✅ Custom rasterizer installed"

cd ../../..
echo "📦 Installing/Updating differentiable renderer..."
cd hy3dgen/texgen/differentiable_renderer
python3 setup.py install
echo "✅ Differentiable renderer installed"
cd ../../..

# Set working directory and environment
echo "✅ Changed to working directory"

# Set up environment variables
export SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
echo "SECRET=$SECRET" > .env
echo "✅ Environment variables configured"

echo "🚀 Starting server..."
# Run the server as root with proper logging
python3 api_server.py --host 0.0.0.0 --port 8000 >> /var/log/hunyuan3d/server.log 2>&1
