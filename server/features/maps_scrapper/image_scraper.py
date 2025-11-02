from serpapi.google_search import GoogleSearch
import os

def fetch_place_image(place):
    params = {
        "engine": "google",
        "q": place,
        "tbm": "isch",  # image search
        "api_key": os.getenv("SERPAPI_KEY")
    }
    search = GoogleSearch(params)
    results = search.get_dict()
    
    if "images_results" in results:
        # return first image URL
        return results["images_results"][0]["original"]
    return None

# Example usage
place = "Eiffel Tower"
image_url = fetch_place_image(place)
print(image_url)
