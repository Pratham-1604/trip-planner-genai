from google import genai
from google.genai import types

def get_llm():
    try:
        client = genai.Client()
        print("Client Created successfully")
        return client
    except Exception as e:
        print(f"Error while creating client: {e}")
        
def invoke_llm(prompt):
    try:
        CLIENT = get_llm()
        MODEL = "gemini-2.5-flash"
        CONFIG=types.GenerateContentConfig(
            thinking_config=types.ThinkingConfig(thinking_budget=0) # Disables thinking
        )
        response = CLIENT.models.generate_content(
            model=MODEL,
            contents=prompt,
            config=CONFIG
        )
        print(response.text)
        return response
    except Exception as e:
        print(f"Error while creating response: {e}")
