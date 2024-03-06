from transformers import ViTImageProcessor, ViTForImageClassification
from PIL import Image
import requests
import sys

if len(sys.argv) != 2:
    print("Usage: python3 image_classify.py filename.jpg")
    sys.exit(1)

filename = sys.argv[1]
image = Image.open(filename).convert('RGB')

model_path = './AiMLChain_server/models/image_clasify_model'
# model_path = './image_clasify_model'

processor = ViTImageProcessor.from_pretrained(model_path)
model = ViTForImageClassification.from_pretrained(model_path)

inputs = processor(images=image, return_tensors="pt")
outputs = model(**inputs)
logits = outputs.logits

predicted_class_idx = logits.argmax(-1).item()
print(model.config.id2label[predicted_class_idx])
