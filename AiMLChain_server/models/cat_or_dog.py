
import tensorflow.keras as keras
import os
import warnings
import PIL as pil
import numpy as np
import tensorflow as tf
import sys

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

tf.get_logger().setLevel('INFO')

if len(sys.argv) != 2:
    print("Usage: python3 cat_or_dog.py filename.jpg")
    sys.exit(1)

filename = sys.argv[1]  # Temperature in degrees Celsius

model_path = './AiMLChain_server/models'

model = keras.models.load_model(model_path+"/catvsdog.h5")
pic = np.array(pil.Image.open(filename).resize((255, 255)))

picfolded = np.expand_dims(pic, axis=0)

result = model.predict(picfolded)
if (result >= 0.5):
    print(int(1))
else:
    print(int(2))
