# app/ai/tags.py

from app.ai.constants import TAG_KEYWORDS


def generate_tags(text: str):
    text = text.lower()
    tags = []

    for tag, keywords in TAG_KEYWORDS.items():
        for kw in keywords:
            if kw in text:
                tags.append(tag)
                break

    return list(set(tags))