import re
from llm_client import invoke_llm

def summarize_places(raw_text, place: str):
    prompt = f"""
    You are a travel expert analyzing Reddit user experiences.

    Summarize the key places, activities, and tips people recommend 
    for traveling to {place}. 
    - Highlight food spots, attractions, and unique activities.
    - Avoid personal chatter, only extract useful travel insights.
    - Return a bullet list of recommendations.
    
    Reddit data:
    {raw_text}
    """

    response = invoke_llm(prompt)
    raw_text = response.text.strip()
    cleaned = re.sub(r"```(json|markdown)?", "", raw_text).strip("` \n")
    return cleaned
