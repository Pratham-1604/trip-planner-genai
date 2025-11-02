from llm_client import invoke_llm
import json
import re

from features.maps_scrapper.image_scraper import fetch_place_image

def visualization_generation(itinerary: dict):
    """
    Takes a structured itinerary and transforms it into
    a storytelling JSON with places, using LLM.
    """

    prompt = f"""
    You are a creative travel storyteller. 
    Transform the following itinerary into a JSON response that creates a visual storytelling experience.

    The format must be:
    {{
      "story": "...",
      "days": [
        {{
          "day": 1,
          "title": "...",
          "summary": "...",
          "places": [
            {{
              "id": "...",
              "name": "...",
              "description": "...",
              "latitude": ...,
              "longitude": ...,
              "imageUrl": "...",
              "category": "...",
              "rating": ...,
              "address": "...",
              "tags": ["...", "..."]
            }}
          ]
        }}
      ]
    }}

    Use real locations.
    Here is the itinerary:
    {json.dumps(itinerary, indent=2)}
    """

    # Call LLM
    response = invoke_llm(prompt)

    # Handle response depending on LLM client return type
    raw_text = response.text.strip() if hasattr(response, "text") else str(response).strip()

    # Remove possible code fences
    cleaned = re.sub(r"```(?:json)?", "", raw_text).strip("` \n")

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"[ERROR] Failed to parse LLM output: {e}\nRaw Response:\n{raw_text}")
        return {
            "story": "",
            "days": []
        }


def add_images_to_itinerary(itinerary_json: dict):
    """
    Adds Google image URLs to each place in the itinerary using fetch_place_image().
    - Keeps existing imageUrl if already present.
    - Safely extracts images from pagemap.cse_image or item.link.
    - Uses a default fallback image when unavailable.
    """

    for day in itinerary_json.get("days", []):
        for place in day.get("places", []):
            place_name = place.get("name")

            if not place_name:
                continue

            # Skip if image already exists
            if place.get("imageUrl"):
                continue

            try:
                result = fetch_place_image(place_name)

                # Safely extract image from Google Custom Search result
                image_url = None
                if isinstance(result, dict):
                    if "pagemap" in result and "cse_image" in result["pagemap"]:
                        image_url = result["pagemap"]["cse_image"][0].get("src")
                    elif "link" in result:
                        image_url = result["link"]
                elif isinstance(result, str):
                    image_url = result  # If function returns direct URL

                # Assign image or fallback
                place["imageUrl"] = image_url or "https://via.placeholder.com/400x300?text=No+Image+Available"

            except Exception as e:
                print(f"[ERROR] fetching image for {place_name}: {e}")
                place["imageUrl"] = "https://via.placeholder.com/400x300?text=No+Image+Available"

    return itinerary_json
