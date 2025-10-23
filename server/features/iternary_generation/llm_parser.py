import json
import re
from llm_client import invoke_llm

# Default values if LLM output is incomplete
DEFAULT_SCHEMA = {
    "location": "Unknown",
    "duration_days": 3,
    "budget": 20000,
    "themes": ["general"],
    "when": "unspecified",
    "preferences": "none",
    "include_travel_costs": False,
    "num_travelers": 1,
    "traveler_type": "unspecified",
    "accommodation": "unspecified",
    "food_preferences": "unspecified",
    "transport_mode": "unspecified",
    "local_transport": "unspecified",
    "activity_pace": "balanced",
    "must_include": [],
    "must_exclude": [],
    "purpose": "unspecified"
}

# Clarifying questions for missing or defaulted fields
CLARIFY_QUESTIONS = {
    "location": "Which city or region in India are you planning to visit?",
    "budget": "What's your approximate budget in INR for this trip?",
    "duration_days": "How many days do you want the trip to last?",
    "when": "When are you planning to travel?",
    "num_travelers": "How many people are traveling?",
    "traveler_type": "Is this a solo trip, couple trip, family trip, or group trip?",
    "accommodation": "Do you have a preference for stay (hotel, hostel, homestay, luxury, etc.)?",
    "food_preferences": "Any food preferences or restrictions (veg, non-veg, vegan, Jain, etc.)?",
    "transport_mode": "What will be your transport mode?",
    "include_travel_costs": "Does the budget include the initial travel cost (flight, train, etc)",
    "preferences": "Do you have any personal preferences for this trip?"
}

def llm_parse_user_input(text: str):
    """
    Send user text to LLM to extract trip details into structured JSON.
    """
    prompt = f"""
    You are a travel request parser.  
    Your task is to extract structured trip details from a user's natural language request.  
    Always return a single valid JSON object (no text, no markdown).  
    If information is missing or unclear, use sensible defaults.  

    ### Fields to extract:
    - location: string (city/region in India, or "Unknown")  
    - duration_days: integer (default = 3)  
    - budget: integer (in INR, default = 20000; convert words like "20k" or "twenty thousand" into numbers)  
    - themes: list of strings (choose from ["heritage", "nightlife", "adventure", "food", "nature", "general"]; default ["general"])  
    - when: string (time period, else "unspecified")  
    - preferences: string (special requirements, else "none")  
    - include_travel_costs: string (true if user mentions including transport costs, else unspecified)  
    - num_travelers: integer (default = 1)  
    - traveler_type: string (single, couple, family, group; infer if possible, else "unspecified")  
    - accommodation: string (hotel, hostel, luxury, budget, homestay, etc.; default "unspecified")  
    - food_preferences: string (veg, non-veg, vegan, Jain, etc.; default "unspecified")  
    - transport_mode: string (flight, train, bus, self-drive, etc.; default "unspecified")  
    - local_transport: string (taxi, rental, metro, walk-friendly; default "unspecified")  
    - activity_pace: string (relaxed, balanced, packed; default "balanced")  
    - must_include: list of strings (must-see attractions if specified, else [])  
    - must_exclude: list of strings (things to avoid if specified, else [])  
    - purpose: string (honeymoon, vacation, family trip, backpacking, workation, etc.; default "unspecified")  
    - _extracted_from_user: object (track what was actually provided by user vs defaulted)

    ### Input:
    "{text}"

    ### Output (valid JSON only):
    {{
      "location": "...",
      "duration_days": ...,
      "budget": ...,
      "themes": [...],
      "when": "...",
      "preferences": "...",
      "include_travel_costs": ...,
      "num_travelers": ...,
      "traveler_type": "...",
      "accommodation": "...",
      "food_preferences": "...",
      "transport_mode": "...",
      "local_transport": "...",
      "activity_pace": "...",
      "must_include": [...],
      "must_exclude": [...],
      "purpose": "...",
      "_extracted_from_user": {{
        "location": true/false,
        "duration_days": true/false,
        "budget": true/false,
        "when": true/false,
        "num_travelers": true/false,
        "traveler_type": true/false,
        "accommodation": true/false,
        "food_preferences": true/false,
        "transport_mode": true/false,
        "include_travel_costs": true/false,
        "preferences": true/false
      }}
    }}
    """
    response = invoke_llm(prompt)
    raw_text = response.text.strip()

    # remove ```json ... ``` wrappers if present
    cleaned = re.sub(r"```(json)?", "", raw_text).strip("` \n")

    try:
        parsed = json.loads(cleaned)
    except Exception as e:
        print(f"Error while parsing LLM output: {e}\nRaw output: {raw_text}")
        return DEFAULT_SCHEMA.copy()

    # Merge with defaults
    final = DEFAULT_SCHEMA.copy()
    for key, value in parsed.items():
        final[key] = value

    # Normalize budget (handle "20k", "20,000", "twenty thousand")
    if isinstance(final["budget"], str):
        match = re.match(r"(\d+)(k|K)", final["budget"])
        if match:
            final["budget"] = int(match.group(1)) * 1000
        else:
            try:
                final["budget"] = int(re.sub(r"[^\d]", "", final["budget"])) or DEFAULT_SCHEMA["budget"]
            except:
                final["budget"] = DEFAULT_SCHEMA["budget"]

    return final


def find_missing_fields(parsed: dict):
    """
    Identify fields that are still defaults or unspecified.
    Returns a list of keys that need clarification.
    Uses the _extracted_from_user tracking to determine what was actually provided.
    """
    missing = []
    
    # Check if we have extraction tracking
    extracted = parsed.get("_extracted_from_user", {})
    
    # Use extraction tracking if available, otherwise fall back to value checking
    if not extracted.get("location", False) and parsed["location"] == "Unknown":
        missing.append("location")
    if not extracted.get("budget", False) and parsed["budget"] == DEFAULT_SCHEMA["budget"]:
        missing.append("budget")
    if not extracted.get("duration_days", False) and parsed["duration_days"] == DEFAULT_SCHEMA["duration_days"]:
        missing.append("duration_days")
    if not extracted.get("when", False) and parsed["when"] == "unspecified":
        missing.append("when")
    if not extracted.get("num_travelers", False) and parsed["num_travelers"] == DEFAULT_SCHEMA["num_travelers"]:
        missing.append("num_travelers")
    if not extracted.get("traveler_type", False) and parsed["traveler_type"] == "unspecified":
        missing.append("traveler_type")
    if not extracted.get("accommodation", False) and parsed["accommodation"] == "unspecified":
        missing.append("accommodation")
    if not extracted.get("food_preferences", False) and parsed["food_preferences"] == "unspecified":
        missing.append("food_preferences")
    if not extracted.get("transport_mode", False) and parsed["transport_mode"] == "unspecified":
        missing.append("transport_mode")
    if not extracted.get("include_travel_costs", False) and parsed["include_travel_costs"] == "unspecified":
        missing.append("include_travel_costs")
    if not extracted.get("preferences", False) and parsed["preferences"] == "none":
        missing.append("preferences")

    return missing


def generate_clarifying_questions(parsed: dict):
    """
    Based on missing fields, return a list of clarifying questions to ask the user.
    """
    missing = find_missing_fields(parsed)
    questions = [CLARIFY_QUESTIONS[f] for f in missing if f in CLARIFY_QUESTIONS]
    return questions
