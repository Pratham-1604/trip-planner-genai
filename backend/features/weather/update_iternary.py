import json
import re
from llm_client import invoke_llm
from features.weather.weather_service import get_weather_forecast


def update_itinerary(itinerary: dict, feedback: str, location: str, duration: int) -> dict:
    try:
        weather_summary = get_weather_forecast(location, duration)
    except Exception as e:
        weather_summary = [{"day": "unknown", "condition": "N/A", "note": str(e)}]

    prompt = f"""
    You are an AI trip planner.

    Current Itinerary (JSON):
    {json.dumps(itinerary, indent=2)}

    User Feedback: "{feedback}"
    Latest Weather Forecast: {json.dumps(weather_summary, indent=2)}

    Rules:
    - Keep unchanged days unless feedback or weather requires changes.
    - Modify days realistically if rain or bad weather is forecasted.
    - Maintain valid JSON structure.
    """

    response = invoke_llm(prompt)
    raw_text = response.text.strip()
    cleaned = re.sub(r"^```(json)?|```$", "", raw_text, flags=re.MULTILINE).strip()

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"Error parsing updated itinerary: {e}")
        return itinerary


