from google.colab import drive
drive.mount('/content/drive')


import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras import layers, models, optimizers



train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=40,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    brightness_range=[0.7, 1.3],
    horizontal_flip=True,
    validation_split=0.2 
)



data_dir = '/content/drive/MyDrive/fish_freshness_data'


train_generator = train_datagen.flow_from_directory(
    data_dir,
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    subset='training'
)



validation_generator = train_datagen.flow_from_directory(
    data_dir,
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    subset='validation'

)

print("Detected Classes:", list(train_generator.class_indices.keys()))



base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base_model.trainable = False


model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dropout(0.4),
    layers.Dense(256, activation='relu'),
    layers.Dense(len(train_generator.class_indices), activation='softmax')
])




model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

print("--- Starting initial training---")
initial_epochs = 10
history = model.fit(
    train_generator,
    epochs=initial_epochs,
    validation_data=validation_generator


)



print("Initial Training End")


print("\n--- Starting fine-tuning ---")


base_model.trainable = True


for layer in base_model.layers[:-20]:
    layer.trainable = False



x = base_model.output
x = layers.GlobalAveragePooling2D()(x)
x = layers.BatchNormalization()(x)
x = layers.Dense(256, activation='relu')(x)
x = layers.Dropout(0.5)(x)


predictions = layers.Dense(len(train_generator.class_indices), activation='softmax')(x)

model = models.Model(inputs=base_model.input, outputs=predictions)

fine_tune_learning_rate = 0.0001


model.compile(optimizer=optimizers.Adam(learning_rate=fine_tune_learning_rate),
              loss='categorical_crossentropy',
              metrics=['accuracy'])




fine_tune_epochs = 15

total_epochs = initial_epochs + fine_tune_epochs

print(f"Model recompiled with learning rate: {fine_tune_learning_rate}")

print(f"Training for {fine_tune_epochs} additional epochs (total epochs: {total_epochs}).")

history_fine_tune = model.fit(
    train_generator,
    epochs=total_epochs,
    initial_epoch=history.epoch[-1] + 1,
    validation_data=validation_generator


)


print("Fine-tuning Done Here")

print("Over All Training End Here")
