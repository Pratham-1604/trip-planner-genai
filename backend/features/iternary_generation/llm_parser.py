import json
from llm_client import invoke_llm
import re

def llm_parse_user_input(text: str):
    prompt = f"""
        Extract the following fields from the trip request:
        - Location (city or region in India)
        - Duration in days
        - Budget in INR
        - Themes (heritage, nightlife, adventure, food, nature, general)

        Input: "{text}"
        
        Return ONLY valid JSON (no markdown, no explanation).
        {{
        "location": "...",
        "duration_days": <int>,
        "budget": <int>,
        "themes": [ ... ]
        }}
    """
    print("Prompt: ")
    print(prompt)
    response = invoke_llm(prompt)
    raw_text = response.text.strip()

    # remove ```json ... ``` wrappers if present
    cleaned = re.sub(r"```(json)?", "", raw_text).strip("` \n")

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"Error while calling parser: {e}\nRaw output: {raw_text}")
        return {"location": "Unknown", "duration_days": 3, "budget": 20000, "themes": ["general"]}
