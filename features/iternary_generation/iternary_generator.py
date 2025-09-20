from llm_client import invoke_llm
import json
import re

def generate_itinerary(parsed_input: dict, summary: str):
    duration = parsed_input["duration_days"]
    budget = parsed_input["budget"]
    themes = ", ".join(parsed_input["themes"])

    prompt = f"""
    You are a experienced travel planner with experience of 10 years. 
    Based on the structured trip request below, create a detailed day-by-day itinerary. 
    Include activities, food suggestions, and estimated costs where relevant.
    Ensure the plan matches preferences (themes, pace, accommodation, etc.).

    Trip Request JSON:
    {json.dumps(parsed_input, indent=2)}
    Here is a summary of reviews by people on reddit: {summary}
  
    Rules:
    - Split plan into {duration} days
    - Each day must include morning, afternoon, evening activities
    - Suggest accommodation and transport
    - Keep cost estimates within total budget
    - Focus on themes: {themes}

    Return ONLY valid JSON in this format:
    {{
      "itinerary": [
        {{
          "day": 1,
          "morning": "...",
          "afternoon": "...",
          "evening": "...",
          "estimated_cost": <int>
        }},
        ...
      ],
      "total_estimated_cost": <int>
    }}
    """

    response = invoke_llm(prompt)
    raw_text = response.text.strip()
    cleaned = re.sub(r"```(json)?", "", raw_text).strip("` \n")

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"Error parsing itinerary: {e}\nRaw: {raw_text}")
        return {"itinerary": [], "total_estimated_cost": budget}
