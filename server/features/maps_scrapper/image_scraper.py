import os
import requests
import json
from dotenv import load_dotenv

# Load environment variables from .env file (if present)
load_dotenv()

def fetch_place_image(place):
    # You can either use environment variables or directly paste your key here
    api_key = os.getenv("CUSTOM_SEARCH_API_KEY") or "AIzaSyCUiEDmlNgbF1xWbZugfR-vs9dA8hQer3U"
    cx = os.getenv("CUSTOM_SEARCH_ENGINE_ID") or "76a8fb60be6954e88"

    if not api_key or not cx:
        print("❌ Missing API key or CX. Please set them as environment variables or directly in the script.")
        return None

    url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "q": place,
        "cx": cx,
        "key": api_key,
        "searchType": "image",
        "num": 1,
    }

    print(f"🔍 Searching for: {place}")

    try:
        response = requests.get(url, params=params)
        response.raise_for_status()  # Raises HTTPError if response is not 200
        data = response.json()

        # Debug output (for clarity)
        print(json.dumps(data, indent=2))

        if "items" in data and len(data["items"]) > 0:
            image_url = data["items"][0]["link"]
            print(f"✅ Image found: {image_url}")
            return image_url
        else:
            print("⚠️ No image found for this place.")
            return None

    except requests.exceptions.RequestException as e:
        print(f"❌ Error: {e}")
        return None
    except json.JSONDecodeError:
        print("❌ Failed to parse JSON response.")
        return None


if __name__ == "__main__":
    place = input("Enter place name: ").strip() or "Eiffel Tower"
    fetch_place_image(place)
