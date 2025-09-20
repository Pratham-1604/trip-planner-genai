# personalization.py
def apply_personalization(itinerary: dict, tags: list):
    for day in itinerary["itinerary"]:
        for tag in tags:
            if tag == "heritage":
                day["note"] = "Include cultural and historical sites."
            elif tag == "nightlife":
                day["note"] = "Add evening clubs, lounges, or beach parties."
            elif tag == "adventure":
                day["note"] = "Suggest outdoor/adventure sports."
            elif tag == "food":
                day["note"] = "Include local street food or special restaurants."
    return itinerary