
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()


filename = 'fishes_freshness_model.tflite'

with open(filename, 'wb') as f:
    f.write(tflite_model)

print(f"Your tflite Model Ready Now '{filename}' ")