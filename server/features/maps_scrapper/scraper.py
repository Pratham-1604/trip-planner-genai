import os
import json
import requests
from dotenv import load_dotenv, find_dotenv

# Load .env file
dotenv_path = find_dotenv()
print(f"DEBUG: Found .env at: {dotenv_path}")
load_dotenv(dotenv_path)


def fetch_google_reviews(place, limit=10):
    """
    Fetch Google Maps reviews for a given place using the official Google Places API.
    """
    api_key = os.getenv("GOOGLE_MAP_KEY")
    if not api_key:
        print("❌ ERROR: GOOGLE_MAP_KEY not found in environment variables.")
        return []

    print(f"DEBUG: Searching for place: {place}")

    # Step 1: Find the place_id using Place Search API
    search_url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    search_params = {
        "input": place,
        "inputtype": "textquery",
        "fields": "place_id,name,formatted_address",
        "key": api_key
    }

    search_response = requests.get(search_url, params=search_params)
    search_data = search_response.json()
    print("DEBUG: Place search response:", json.dumps(search_data, indent=2))

    if not search_data.get("candidates"):
        print("⚠️ No place found for query.")
        return []

    place_id = search_data["candidates"][0]["place_id"]
    print(f"✅ Found place_id: {place_id}")

    # Step 2: Get reviews using Place Details API
    details_url = "https://maps.googleapis.com/maps/api/place/details/json"
    details_params = {
        "place_id": place_id,
        "fields": "name,rating,reviews,user_ratings_total",
        "key": api_key
    }

    details_response = requests.get(details_url, params=details_params)
    details_data = details_response.json()
    print("DEBUG: Place details response:", json.dumps(details_data, indent=2))

    if "result" in details_data and "reviews" in details_data["result"]:
        reviews = details_data["result"]["reviews"][:limit]
        print(f"✅ Found {len(reviews)} reviews for {place}")
        return reviews
    else:
        print("⚠️ No reviews found for this place.")
        return []


def preprocess_google_reviews(reviews):
    """
    Convert reviews into a single text blob for summarization.
    """
    if not reviews:
        print("DEBUG: No reviews to preprocess")
        return ""

    text_corpus = []
    for i, review in enumerate(reviews):
        text = review.get("text")
        if text:
            print(f"DEBUG: Review {i+1} length: {len(text)}")
            text_corpus.append(text)

    result = " ".join(text_corpus)[:2000]  # Limit text for LLMs
    print(f"DEBUG: Combined text corpus length: {len(result)}")
    return result


def test_reviews(place_name):
    print(f"\n=== Testing reviews for: {place_name} ===")
    reviews = fetch_google_reviews(place_name, limit=5)
    if reviews:
        print(f"Successfully fetched {len(reviews)} reviews")
        text = preprocess_google_reviews(reviews)
        print(f"Text preview: {text[:200]}...")
    else:
        print("No reviews found")


if __name__ == "__main__":
    test_reviews("Jimmis burger")
