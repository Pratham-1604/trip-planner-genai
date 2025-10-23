# itinerary_generator.py
from llm_client import invoke_llm
import json
import re
from features.weather.weather_service import get_weather_forecast




def generate_itinerary(parsed_input: dict, summary: str):
    location = parsed_input["location"]
    duration = parsed_input["duration_days"]
    budget = parsed_input["budget"]
    themes = ", ".join(parsed_input["themes"])

    # ✅ Get weather forecast
    try:
        weather_summary = get_weather_forecast(location, duration)
    except Exception as e:
        weather_summary = [{"day": "unknown", "condition": "N/A", "note": str(e)}]

    prompt = f"""
    You are an AI trip planner.
    Generate a {duration}-day itinerary for {location}, India.
    Traveler budget: {budget} INR.
    Interests: {themes}.
    Here is a summary of reviews: {summary}
    Weather forecast for the trip: {json.dumps(weather_summary, indent=2)}

    Rules:
    - Adapt outdoor activities if rain probability is high.
    - Suggest indoor activities on rainy days.
    - Consider temperature ranges when planning activities.
    - Split into {duration} days (morning, afternoon, evening).
    - Suggest accommodation and transport.
    - Keep total cost under budget.
    - Return valid JSON only.
    """

    response = invoke_llm(prompt)
    raw_text = response.text.strip()
    cleaned = re.sub(r"```(json)?", "", raw_text).strip("` \n")

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"Error parsing itinerary: {e}\nRaw: {raw_text}")
        return {"itinerary": [], "total_estimated_cost": budget}
    
# Example usage
# parsed_input = {"location": "Goa", "duration_days": 5, "budget": 30000, "themes": ["beach", "nightlife", "food"]}
# summary = "Goa is famous for its beaches, vibrant nightlife, and seafood."      
# itinerary = generate_itinerary(parsed_input, summary)
# print(json.dumps(itinerary, indent=2))
# print(json.dumps(itinerary, indent=2))
# --- IGNORE ---
