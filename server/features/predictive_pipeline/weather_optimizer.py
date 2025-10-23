from llm_client import invoke_llm
from features.weather.weather_service import get_weather_forecast
from features.predictive_pipeline.travel_optimizer import optimize_itinerary_sequence
from features.iternary_generation.iternary_generator import generate_itinerary
import json
import re


def optimize_itinerary(itinerary_json: dict, parsed_input: dict, start_day: int = 2, city: str = "Goa"):
    """
    Optimize itinerary from start_day onward based on:
    - Weather forecast (indoor vs outdoor activities)
    - Travel optimization (minimize travel time / better sequence)
    
    Also provide reasons for each change.
    """

    itinerary = itinerary_json.get("itinerary", [])
    total_days = len(itinerary)
    print(f"Total days in itinerary: {total_days}, Starting optimization from day {start_day}")
    if total_days == 0 or start_day > total_days:
        return itinerary_json
    
    print(f"success")

    # 0-indexed
    start_idx = start_day - 1

    # Keep previous days unchanged
    previous_days = itinerary[:start_idx]

    # -------------------------
    # 1️⃣ Weather Optimization
    # -------------------------
    forecast = get_weather_forecast(city, days=total_days)[start_idx:]

    weather_summary = []
    for day, w in enumerate(forecast, start=start_day):
        weather_summary.append(f"Day {day}: {w['condition']}, Max: {w['max_temp']}°C, Min: {w['min_temp']}°C")

    weather_text = "\n".join(weather_summary)

    weather_prompt = f"""
    You are an experienced travel planner. 
    Regenerate the itinerary only from day {start_day} onward for this trip.

    Weather Forecast:
    {weather_text}

    Trip Request JSON:
    {json.dumps(parsed_input, indent=2)}

    Rules:
    - Adjust activities based on weather (rain = indoor, sunny = outdoor)
    - Return ONLY JSON with itinerary + total cost
    """

    weather_response = invoke_llm(weather_prompt)
    raw_weather = weather_response.text.strip()
    cleaned_weather = re.sub(r"```(json)?", "", raw_weather).strip("` \n")

    try:
        print(f"Weather LLM Response: {cleaned_weather}")
        weather_json = json.loads(cleaned_weather)
        weather_itinerary_dict = weather_json.get("itinerary", {})
        weather_opt = [weather_itinerary_dict[key] for key in sorted(weather_itinerary_dict.keys())]

        # weather_opt = json.loads(cleaned_weather).get("itinerary", [])
    except Exception as e:
        print(f"Error parsing weather itinerary: {e}")
        weather_opt = itinerary[start_idx:]  # fallback

    # -------------------------
    # 2️⃣ Travel Optimization
    # -------------------------
    travel_opt = optimize_itinerary_sequence(weather_opt)  # your travel optimizer

    # -------------------------
    # 3️⃣ Compare + Add Reasons
    # -------------------------
    optimized_with_reasons = []
    for orig_day, new_day, final_day in zip(itinerary[start_idx:], weather_opt, travel_opt):
        reasons = []

        # Weather reasoning
        if orig_day.get("morning") != new_day.get("morning") or \
           orig_day.get("afternoon") != new_day.get("afternoon") or \
           orig_day.get("evening") != new_day.get("evening"):
            reasons.append("Changed due to weather forecast (e.g., moved outdoor → indoor activity).")

        # Travel reasoning
        if new_day != final_day:
            reasons.append("Adjusted sequence to reduce travel time between activities.")

        final_day["reasons"] = reasons
        optimized_with_reasons.append(final_day)

    # Merge unchanged + optimized
    optimized_itinerary = previous_days + optimized_with_reasons
    total_cost = sum(day.get("estimated_cost", 0) for day in optimized_itinerary)

    return {
        "itinerary": optimized_itinerary,
        "optimized_with_reasons": optimized_with_reasons,
        "total_estimated_cost": total_cost
    }
