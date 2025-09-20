from serpapi import GoogleSearch
import os
import json
from dotenv import load_dotenv

# Load environment variables from .env file
from dotenv import load_dotenv, find_dotenv
dotenv_path = find_dotenv()
print(f"DEBUG: Found .env at: {dotenv_path}")
load_dotenv(dotenv_path)

def fetch_google_reviews(place, limit=10):
    """
    Fetch Google Maps reviews for a given place using SerpAPI.
    """
    # Search for the place to get its place_id
    print(f"DEBUG: Searching for place: {place}")
    api_key = os.getenv('SERPAPI_KEY')
    print(f"DEBUG SERPAPI_KEY exists: {bool(api_key)}")
    
    if not api_key:
        print("ERROR: SERPAPI_KEY environment variable not set!")
        print("Please set it in your .env file or as an environment variable")
        return []
    
    search = GoogleSearch({
        "engine": "google_maps",
        "q": place,
        "api_key": api_key
    })
    
    try:
        place_results = search.get_dict()
        print(f"DEBUG: Full response keys: {place_results.keys()}")
        print(f"DEBUG: Full response: {json.dumps(place_results, indent=2)[:1000]}...")  # First 1000 chars
        
        # Check different possible structures
        place_id = None
        
        # Method 1: Check if place_results exists
        if "place_results" in place_results:
            place_id = place_results["place_results"].get("place_id")
            print(f"DEBUG: Found place_id via place_results: {place_id}")
        
        # Method 2: Check if local_results exists (common structure)
        elif "local_results" in place_results and len(place_results["local_results"]) > 0:
            place_id = place_results["local_results"][0].get("place_id")
            print(f"DEBUG: Found place_id via local_results: {place_id}")
        
        # Method 3: Check if it's directly in the response
        elif "place_id" in place_results:
            place_id = place_results["place_id"]
            print(f"DEBUG: Found place_id directly: {place_id}")
        
        if not place_id:
            print("DEBUG: No place_id found in any expected location")
            return []

        print(f"DEBUG: Using place_id: {place_id}")
        
        # Fetch reviews for the place
        review_search = GoogleSearch({
            "engine": "google_maps_reviews",
            "place_id": place_id,
            "api_key": api_key
        })
        
        reviews_data = review_search.get_dict()
        print(f"DEBUG: Reviews response keys: {reviews_data.keys()}")
        
        if "reviews" in reviews_data:
            reviews = reviews_data["reviews"]
            print(f"DEBUG: Found {len(reviews)} reviews")
            return reviews[:limit]
        else:
            print("DEBUG: No 'reviews' key found in response")
            print(f"DEBUG: Reviews response: {json.dumps(reviews_data, indent=2)[:500]}...")
            return []
            
    except Exception as e:
        print(f"DEBUG: Error occurred: {str(e)}")
        return []

def preprocess_google_reviews(reviews):
    """
    Convert reviews into a single text blob for summarization.
    """
    if not reviews:
        print("DEBUG: No reviews to preprocess")
        return ""
        
    text_corpus = []
    for i, r in enumerate(reviews):
        print(f"DEBUG: Review {i} keys: {r.keys()}")
        if "text" in r:
            text_corpus.append(r["text"])
            print(f"DEBUG: Added review text (length: {len(r['text'])})")
        elif "snippet" in r:  # Alternative field name
            text_corpus.append(r["snippet"])
            print(f"DEBUG: Added review snippet (length: {len(r['snippet'])})")
    
    result = " ".join(text_corpus[:2000])  # keep it manageable for LLM
    print(f"DEBUG: Final text corpus length: {len(result)}")
    return result

# Test function
def test_reviews(place_name):
    print(f"\n=== Testing reviews for: {place_name} ===")
    reviews = fetch_google_reviews(place_name, limit=5)
    if reviews:
        print(f"Successfully fetched {len(reviews)} reviews")
        text = preprocess_google_reviews(reviews)
        if text:
            print(f"Text preview: {text[:200]}...")
        else:
            print("No text extracted from reviews")
    else:
        print("No reviews found")

# Example usage:
if __name__ == "__main__":
    test_reviews("Goa")