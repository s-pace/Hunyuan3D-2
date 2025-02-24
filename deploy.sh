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
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --accelerator=count=1,type=nvidia-l4 \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20250222-175338,image=projects/ml-images/global/images/c0-deeplearning-common-cu121-v20240214-debian-11,mode=rw,size=100,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud

gcloud compute instances start hunyuan3d-vm
gcloud compute ssh hunyuan3d-vm

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3-pip git wget
git clone https://huggingface.co/spaces/tencent/Hunyuan3D-2

git clone https://github.com/s-pace/Hunyuan3D-2.git
pip install -r requirements.txt
# for texture
cd hy3dgen/texgen/custom_rasterizer
python3 setup.py install
cd ../../..
cd hy3dgen/texgen/differentiable_renderer
python3 setup.py install

# Add this to your startup script or deployment script
export SECRET="secret"

# Start your application
python api_server.py
