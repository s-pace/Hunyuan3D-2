from hy3dgen.shapegen import Hunyuan3DDiTFlowMatchingPipeline
from hy3dgen.texgen import Hunyuan3DPaintPipeline
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

shape_pipeline = Hunyuan3DDiTFlowMatchingPipeline.from_pretrained('tencent/Hunyuan3D-2')
texture_pipeline = Hunyuan3DPaintPipeline.from_pretrained('tencent/Hunyuan3D-2')

@app.route('/generate', methods=['POST'])
def generate():
    image_url = request.json['image_url']
    mesh = shape_pipeline(image=image_url)
    textured_mesh = texture_pipeline(mesh, image=image_url)
    # Save or process the textured_mesh as needed
    return jsonify({"status": "success"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8000)))
