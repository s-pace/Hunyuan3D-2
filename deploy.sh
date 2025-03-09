#!/bin/bash

# Create firewall rule
gcloud compute firewall-rules create allow-port-8000 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:8000 \
    --source-ranges=0.0.0.0/0
echo "✅ Firewall rule created to allow port 8000"

# Create VM instance
gcloud compute instances create hunyuan3d-vm \
    --project=print-jam-map \
    --zone=europe-west4-c \
    --machine-type=g2-standard-8 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account=498951535392-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/cloud-platform \
    --accelerator=count=1,type=nvidia-l4 \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20250222-175338,image=projects/ml-images/global/images/c0-deeplearning-common-cu121-v20240214-debian-11,mode=rw,size=100,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud
echo "✅ VM instance created successfully"

# Create the startup script in a separate file
cat > startup-script.sh << 'EOF'
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
EOF
echo "✅ Startup script created"

# Set the startup script as metadata
gcloud compute instances add-metadata hunyuan3d-vm \
    --zone=europe-west4-c \
    --metadata-from-file=startup-script=startup-script.sh
echo "✅ Startup script added to VM metadata"

# Clean up the temporary script
rm startup-script.sh
echo "✅ Temporary script cleaned up"

# Start the instance
gcloud compute instances start hunyuan3d-vm
echo "✅ VM instance started"

echo "🔄 Connecting to VM via SSH..."
# SSH into the instance
gcloud compute ssh hunyuan3d-vm
