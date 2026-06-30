import joblib

model = joblib.load("app/ai/ml/models/model.pkl")
vectorizer = joblib.load("app/ai/ml/models/vectorizer.pkl")

def predict_complaint(text: str):
    vec = vectorizer.transform([text])
    label = model.predict(vec)[0]

    return {
        "prediction": label
    }