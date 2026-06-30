# app/ai/priority.py

from app.ai.constants import HIGH_PRIORITY_KEYWORDS


def predict_priority(text: str) -> str:
    text = text.lower()

    for keyword in HIGH_PRIORITY_KEYWORDS:
        if keyword in text:
            return "high"

    return "low"