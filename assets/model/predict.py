from google.colab import files
from tensorflow.keras.preprocessing import image
import numpy as np
import matplotlib.pyplot as plt


uploaded = files.upload()


labels_indices = train_generator.class_indices
class_names = sorted(labels_indices, key=labels_indices.get)


for fn in uploaded.keys():
    img_path = '/content/' + fn
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array /= 255.0


    predictions = model.predict(img_array)[0]
    predicted_index = np.argmax(predictions)
    detected_label = class_names[predicted_index]
    confidence = predictions[predicted_index] * 100


    print(f"\n================ ANALYSIS for {fn} ================")


    print("Confidence Breakdown:")


    
    for i, name in enumerate(class_names):
        print(f"- {name}: {predictions[i]*100:.2f}%")




    print(f"\nFINAL DECISION: {detected_label} ({confidence:.2f}%)")



    if detected_label == 'data_invalid' or confidence < 40.0:
        print(" RESULT: INVALID OBJECT!")


    else:
        parts = detected_label.split('_')
        species = parts[0].upper()
        freshness = parts[1].upper()


        print(f" SPECIES: {species} |  STATUS: {freshness}")

        if freshness == 'FRESH':
            print("Result: Fresh")

        elif 'MODERATE' in freshness or 'MEDIUM' in freshness:
            print("Result: Moderate")


        elif freshness == 'SPOILED':
            print("Result: Spoiled ")



    plt.imshow(img)
    plt.axis('off')
    plt.show()