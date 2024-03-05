import joblib
import numpy as np
import sys
import warnings
warnings.filterwarnings('ignore')

model_path = './AiMLChain_server/models/weather_forecasting_model.pkl'
model = joblib.load(model_path)

if len(sys.argv) != 4:
    print("Usage: python script_name.py <temperature> <humidity> <pressure>")
    sys.exit(1)

temperature = float(sys.argv[1])  # Temperature in degrees Celsius
humidity = float(sys.argv[2])  # Humidity in percentage
pressure = float(sys.argv[3])  # Atmospheric pressure in hPa

features = np.array([[temperature, humidity, pressure]])

predicted_temperature = model.predict(features)

print(abs(int(predicted_temperature[0])))
