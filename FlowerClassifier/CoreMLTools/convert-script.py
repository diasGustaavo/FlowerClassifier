import tensorflow as tf
import tensorflow_hub as hub
import coremltools as ct

MODEL_URL = "https://tfhub.dev/google/inaturalist/inception_v3/feature_vector/5"
# I will post this model URL in the description
# You can ofcourse use your own model from TF Hub

model = tf.keras.Sequential([tf.keras.layers.InputLayer(input_shape=(299, 299, 3)), hub.KerasLayer(MODEL_URL)]) # Our model requires an input of 224x224. 
# hub.KerasLayer is a tfhub function that loads in a tfhub model

model.build([1, 299, 299, 3])

# Let's convert this to CoreML
mlmodel = ct.convert(model, inputs=[ct.ImageType(scale=1/127, shape=[1, 299, 299, 3])])

# We use the univeral coreml model converter. Now, we just have to save it
mlmodel.save("FlowerClassifier.mlmodel")
# our model type is "mlmodel". You can then load this into xcode and implement this in your app