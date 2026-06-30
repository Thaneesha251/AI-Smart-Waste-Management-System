import pandas as pd
import pickle
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline

# Load dataset
df = pd.read_csv("app/ai/ml/dataset.csv")

X = df["text"]
y = df["label"]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Create pipeline (clean + robust)
model = Pipeline([
    ("tfidf", TfidfVectorizer()),
    ("clf", LogisticRegression(max_iter=200))
])

# Train
model.fit(X_train, y_train)

# Save model
with open("app/ai/ml/model.pkl", "wb") as f:
    pickle.dump(model, f)

print("✅ ML Model trained successfully")