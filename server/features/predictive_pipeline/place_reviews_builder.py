import re
from collections import defaultdict

def build_place_reviews_map(reddit_comments, places_list=None):
    """
    Build a map of place -> list of context sentences from Reddit comments.
    Auto-detects place names if places_list is not provided.
    """
    place_reviews_map = defaultdict(list)

    for comment in reddit_comments:
        sentences = re.split(r"[.!?]", comment)
        for sentence in sentences:
            sentence = sentence.strip()
            if not sentence:
                continue

            if places_list:
                for place in places_list:
                    if place.lower() in sentence.lower():
                        place_reviews_map[place].append(sentence)
            else:
                words = re.findall(r"\b[A-Z][a-zA-Z]+\b", sentence)
                for word in words:
                    place_reviews_map[word].append(sentence)

    return dict(place_reviews_map)
