from features.weather.weather_service import get_weather_forecast

def optimize_weather(itinerary_json, city):
    forecast = get_weather_forecast(city, days=len(itinerary_json["itinerary"]))
    
    for day_data, day_itin in zip(forecast, itinerary_json.get("itinerary", [])):
        condition = day_data["condition"].lower()
        for key in ["morning", "afternoon", "evening"]:
            if "rain" in condition:
                day_itin[key] += " (Consider indoor alternative due to rain)"
            elif "sunny" in condition or "clear" in condition:
                day_itin[key] += " (Great time for outdoor activities)"
    return itinerary_json
