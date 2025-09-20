import requests
import os
from dotenv import load_dotenv
load_dotenv()

WEATHER_API_KEY = os.getenv("WEATHER_API_KEY")  # load from .env

def get_weather_forecast(city: str, days: int = 5):
    """Fetch weather forecast for a city."""
    url = "http://api.weatherapi.com/v1/forecast.json"
    params = {
        "key": WEATHER_API_KEY,
        "q": city,
        "days": days,
        "aqi": "no",
        "alerts": "no"
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        forecast = [
            {
                "day": i + 1,
                "condition": f["day"]["condition"]["text"],
                "max_temp": f["day"]["maxtemp_c"],
                "min_temp": f["day"]["mintemp_c"],
                "rain_chance": f["day"]["daily_chance_of_rain"],
            }
            for i, f in enumerate(data["forecast"]["forecastday"])
        ]
        return forecast
    else:
        raise Exception(f"Weather API error: {response.text}")
# Example usage
city = "Goa"
forecast = get_weather_forecast(city)
print(f"5-Day Weather Forecast for {city}:")
for day in forecast:
    print(f"Day {day['day']}: {day['condition']}, Max: {day['max_temp']}°C, Min: {day['min_temp']}°C, Rain Chance: {day['rain_chance']}%")
    