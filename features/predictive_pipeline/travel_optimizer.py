import googlemaps
import os
from dotenv import load_dotenv
import datetime

load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_MAP_KEY")
gmaps = googlemaps.Client(key=GOOGLE_API_KEY)

def fetch_travel_time_matrix(locations, departure_time=None):
    n = len(locations)
    matrix = [[0]*n for _ in range(n)]
    
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            resp = gmaps.distance_matrix(
                origins=[locations[i]],
                destinations=[locations[j]],
                mode="driving",
                departure_time=departure_time
            )
            element = resp["rows"][0]["elements"][0]
            duration_sec = element.get("duration", {}).get("value", 0)
            matrix[i][j] = duration_sec // 60
    return matrix

def optimize_itinerary_sequence(itinerary_json, start_time=None, default_activity_duration=120):
    if start_time is None:
        start_time = datetime.datetime.now()

    reasons = []

    for day in itinerary_json.get("itinerary", []):
        places = [day.get("morning"), day.get("afternoon"), day.get("evening")]
        places = [p for p in places if p]
        if len(places) <= 1:
            continue

        current_departure = start_time
        ordered = [places[0]]
        remaining = places[1:]

        while remaining:
            travel_matrix = fetch_travel_time_matrix([ordered[-1]] + remaining, departure_time=current_departure)
            travel_times = travel_matrix[0][1:]
            next_idx = travel_times.index(min(travel_times))

            chosen_place = remaining[next_idx]
            chosen_time = travel_times[next_idx]

            # Store reasoning
            reasons.append(
                f"From {ordered[-1]} → {chosen_place} "
                f"was chosen because travel time = {chosen_time} mins, "
                f"shorter than alternatives {dict(zip(remaining, travel_times))}"
            )

            current_departure += datetime.timedelta(minutes=chosen_time + default_activity_duration)
            ordered.append(remaining.pop(next_idx))
        
        day["morning"], day["afternoon"], day["evening"] = (ordered + ["", ""])[:3]

    return itinerary_json, reasons


# Mock itinerary with deliberately bad order
itinerary = {
    "itinerary": [
        {
            "day": 1,
            "morning": "Lalbagh Botanical Garden, Bangalore",
            "afternoon": "Kempegowda International Airport, Bangalore",  # Far outside city
            "evening": "Cubbon Park, Bangalore"
        }
    ]
}

print("📍 Original Itinerary:")
for day in itinerary["itinerary"]:
    print(day)

optimized, reasons = optimize_itinerary_sequence(
    itinerary_json=itinerary,
    start_time=datetime.datetime.now(),
    default_activity_duration=90
)

print("\n✅ Optimized Itinerary:")
for day in optimized["itinerary"]:
    print(day)

print("\n📌 Reasons for Optimization:")
for r in reasons:
    print("-", r)
