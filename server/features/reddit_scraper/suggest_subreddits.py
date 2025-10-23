import re
import json
from llm_client import invoke_llm

def suggest_subreddits(place: str, max_subs=5):
    prompt = f"""
    You are an AI travel assistant. 
    A user wants to gather authentic travel advice about "{place}" from Reddit. 

    Task:
    - Suggest up to {max_subs} relevant subreddits where travelers commonly discuss tips, itineraries, recommendations, nightlife, food, or experiences for {place}.
    - Prioritize subreddits that exist and are active.
    - Return ONLY a JSON array of subreddit names (no r/ prefix).

    Example:
    ["travel", "solotravel", "IndiaTravel", "backpacking", "Goa"]

    Now suggest subreddits:
    """

    response = invoke_llm(prompt)
    raw_text = response.text.strip()

    # Clean ```json wrapper if present
    cleaned = re.sub(r"```(json)?", "", raw_text).strip("` \n")

    try:
        subreddits = json.loads(cleaned)
        return subreddits[:max_subs]
    except Exception as e:
        print(f"Error parsing subreddits: {e}")
        return ["travel", "solotravel", "IndiaTravel"]  # Fallback
