# app/ai/classifier.py

from app.ai.constants import WASTE_CATEGORIES, RECYCLABLE_ITEMS


def classify_waste(text: str):
    text = text.lower()

    for item in RECYCLABLE_ITEMS:
        if item in text:
            return {
                "category": "recyclable",
                "matched_item": item
            }

    for category in WASTE_CATEGORIES:
        if category in text:
            return {
                "category": category,
                "matched_item": None
            }

    return {
        "category": "general",
        "matched_item": None
    }