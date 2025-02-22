from fastapi import FastAPI
from pydantic import BaseModel
import torch
from diffusers import StableDiffusionPipeline

# Initialize FastAPI app
app = FastAPI()

# Load Hunyuan3D model
model_id = "TencentARC/Hunyuan3D"
pipe = StableDiffusionPipeline.from_pretrained(model_id, torch_dtype=torch.float16)
pipe.to("cuda")  # Ensure GPU usage if available

class RequestData(BaseModel):
    prompt: str

@app.post("/generate")
async def generate_image(request: RequestData):
    image = pipe(request.prompt).images[0]
    image_path = "output.png"
    image.save(image_path)
    return {"image_path": image_path, "message": "Image generated successfully"}

@app.get("/")
def root():
    return {"message": "Hunyuan3D-2 API is running"}
