import json
import re
from llm_client import invoke_llm

def update_itinerary(itinerary: dict, feedback: str) -> dict:
    """
    Updates the itinerary based on user feedback using LLM.

    Args:
        itinerary (dict): Current itinerary in JSON/dict format.
        feedback (str): User feedback (can be day-specific or general).

    Returns:
        dict: Updated itinerary with feedback incorporated.
    """

    prompt = f"""
    You are an AI trip planner.
    
    Current Itinerary (JSON):
    {json.dumps(itinerary, indent=2)}

    User Feedback: "{feedback}"

    Rules:
    - Keep unchanged days/activities unless directly impacted by feedback.
    - Apply modifications strictly based on feedback.
    - Maintain consistency in structure (same day numbering, keys, etc.).
    - Always return the full updated itinerary as valid JSON only.
    """

    print("Prompt sent to LLM:")
    print(prompt)

    response = invoke_llm(prompt)
    raw_text = response.text.strip()

    # Clean possible markdown wrappers from LLM response
    cleaned = re.sub(r"^```(json)?|```$", "", raw_text, flags=re.MULTILINE).strip()

    try:
        return json.loads(cleaned)
    except Exception as e:
        print(f"Error parsing updated itinerary: {e}")
        return itinerary
