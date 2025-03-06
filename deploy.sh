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

# Set the command to run when starting the instance
gcloud compute instances add-metadata hunyuan3d-vm \
    --zone=europe-west4-c \
    --metadata=startup-script-command="cd /home/$(whoami)/Hunyuan3D-2 && export SECRET=yoursupersecretkey && python api_server.py"

gcloud compute instances start hunyuan3d-vm
gcloud compute ssh hunyuan3d-vm
