import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from features.itinerary_generation.itinerary_generator import generate_itinerary
from features.reddit_scraper.scraper import fetch_reddit_comments
from local_intelligence import extract_local_tips
from crowd_optimizer import optimize_crowd
from weather_optimizer import optimize_weather
from humanise_iternary import narrative_itinerary
from place_reviews_builder import build_place_reviews_map
from travel_optimizer import optimize_itinerary_sequence

def hackathon_itinerary_pipeline(parsed_input, summary):
    # Base itinerary
    itinerary_data = generate_itinerary(parsed_input, summary)

    # Fetch Reddit comments & extract local tips
    reddit_comments = fetch_reddit_comments(parsed_input["location"])
    local_tips = extract_local_tips(reddit_comments)

    # Build dynamic place reviews map
    place_reviews_map = build_place_reviews_map(reddit_comments)

    # Crowd optimization
    itinerary_data = optimize_crowd(itinerary_data, place_reviews_map)

    # Weather optimization
    itinerary_data = optimize_weather(itinerary_data, parsed_input["location"])

    # Travel optimization
    itinerary_data = optimize_itinerary_sequence(itinerary_data)

    # Narrative storytelling
    story = narrative_itinerary(itinerary_data, local_tips)
    return story


# Example usage

parsed_input = {
    "location": "Jaipur",
    "duration_days": 2,
    "budget": 5000,
    "themes": ["heritage", "food"]
}

summary = "Visitors love Jaipur for its forts, palaces, and street food."

story = hackathon_itinerary_pipeline(parsed_input, summary)
print(story)

