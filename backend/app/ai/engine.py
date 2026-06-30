# app/ai/engine.py

from app.ai.classifier import classify_waste
from app.ai.priority import predict_priority
from app.ai.tags import generate_tags


def analyze_complaint(text: str):
    classification = classify_waste(text)
    priority = predict_priority(text)
    tags = generate_tags(text)

    return {
        "classification": classification,
        "priority": priority,
        "tags": tags
    }