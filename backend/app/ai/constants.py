# app/ai/constants.py

# Waste categories for classification
WASTE_CATEGORIES = [
    "organic",
    "plastic",
    "metal",
    "paper",
    "glass",
    "electronic",
    "hazardous",
    "general"
]

# Items that are recyclable
RECYCLABLE_ITEMS = [
    "plastic bottle",
    "newspaper",
    "cardboard",
    "glass bottle",
    "aluminum can",
    "metal scrap"
]

# Keywords that indicate HIGH priority complaints
HIGH_PRIORITY_KEYWORDS = [
    "overflow",
    "sewage",
    "dead animal",
    "smell",
    "hazard",
    "fire",
    "injury",
    "blocked drain",
    "flood"
]

# Tagging keywords for AI tagging system
TAG_KEYWORDS = {
    "garbage": ["waste", "trash", "garbage", "litter"],
    "cleanliness": ["dirty", "unclean", "filthy"],
    "drainage": ["drain", "sewage", "blockage"],
    "collection": ["not collected", "missed pickup"]
}