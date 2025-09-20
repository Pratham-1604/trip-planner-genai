from llm_client import invoke_llm
import json
import re

from llm_client import invoke_llm
import json
import re

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

