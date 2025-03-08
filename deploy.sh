#!/bin/bash

gcloud compute firewall-rules create allow-port-8000 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:8000 \
    --source-ranges=0.0.0.0/0

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

# Create the startup script in a separate file
cat > startup-script.sh << 'EOF'
#!/bin/bash

# Create a log directory with proper permissions
mkdir -p /var/log/hunyuan3d
chmod 755 /var/log/hunyuan3d

# Install system dependencies
apt-get update && apt-get upgrade -y
apt-get install -y python3-pip git wget nvidia-driver-525 nvidia-cuda-toolkit

# Clone the repository if it doesn't exist
if [ ! -d "/root/Hunyuan3D-2" ]; then
    cd /root
    git clone https://github.com/s-pace/Hunyuan3D-2.git
    cd Hunyuan3D-2
    
    # Install Python dependencies
    pip install -r requirements.txt
    
    # Install texture dependencies
    cd hy3dgen/texgen/custom_rasterizer
    python3 setup.py install
    cd ../../..
    cd hy3dgen/texgen/differentiable_renderer
    python3 setup.py install
    cd ../../..
fi

# Set working directory and environment
cd /root/Hunyuan3D-2

# Set up environment variables
export SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
echo "SECRET=$SECRET" > .env

# Run the server as root with proper logging
python3 api_server.py --host 0.0.0.0 --port 8000 >> /var/log/hunyuan3d/server.log 2>&1
EOF

# Set the startup script as metadata
gcloud compute instances add-metadata hunyuan3d-vm \
    --zone=europe-west4-c \
    --metadata-from-file=startup-script=startup-script.sh

# Clean up the temporary script
rm startup-script.sh

# Start the instance
gcloud compute instances start hunyuan3d-vm

# SSH into the instance
gcloud compute ssh hunyuan3d-vm
