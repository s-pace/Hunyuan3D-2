FROM registry.hf.space/tencent-hunyuan3d-2:latest

# Expose port 7860 for the application
EXPOSE 8000

# Set platform for compatibility
ENV DOCKER_DEFAULT_PLATFORM=linux/amd64

# Command to run the application
CMD ["python", "hg_app.py"]
