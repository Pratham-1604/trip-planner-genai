import random

def narrative_itinerary(itinerary_json):
    """
    Converts itinerary JSON into a human-friendly, story-like narrative with varied expressions.
    """
    morning_phrases = [
        "start your morning with",
        "begin the day by enjoying",
        "kick off the day with",
        "wake up to"
    ]
    
    afternoon_phrases = [
        "spend the afternoon exploring",
        "enjoy the afternoon visiting",
        "take some time to wander around",
        "dive into"
    ]
    
    evening_phrases = [
        "wrap up the day with",
        "as the sun sets, experience",
        "end the day enjoying",
        "finish off with"
    ]

    story = ""
    for day in itinerary_json.get("itinerary", []):
        day_num = day.get("day", "?")
        morning = day.get("morning", "")
        afternoon = day.get("afternoon", "")
        evening = day.get("evening", "")
        cost = day.get("estimated_cost", 0)

        story += f"🌅 Day {day_num}: {random.choice(morning_phrases)} {morning.lower()}. "
        story += f"{random.choice(afternoon_phrases)} {afternoon.lower()}. "
        story += f"{random.choice(evening_phrases)} {evening.lower()}. "
        story += f"Estimated cost: ₹{cost}.\n\n"

    total_cost = itinerary_json.get("total_estimated_cost", 0)
    story += f"💰 Total estimated cost for your {len(itinerary_json.get('itinerary', []))}-day trip: ₹{total_cost}."
    
    return story
