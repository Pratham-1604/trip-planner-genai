def predict_best_time(place_reviews):
    morning_count = sum("morning" in r.lower() for r in place_reviews)
    afternoon_count = sum("afternoon" in r.lower() for r in place_reviews)
    return "morning" if morning_count > afternoon_count else "afternoon"

def optimize_crowd(itinerary_json, place_reviews_map):
    for day in itinerary_json.get("itinerary", []):
        for key in ["morning", "afternoon", "evening"]:
            activity = day.get(key, "")
            if activity in place_reviews_map:
                best_time = predict_best_time(place_reviews_map[activity])
                day[key] += f" (Best time: {best_time})"
    return itinerary_json

