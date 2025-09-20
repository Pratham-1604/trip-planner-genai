from fastapi import FastAPI
from fastapi.responses import JSONResponse
from features.iternary_generation.llm_parser import llm_parse_user_input, generate_clarifying_questions
from features.iternary_generation.iternary_generator import generate_itinerary
from features.iternary_generation.basic_tag_personalization import apply_personalization
from features.reddit_scraper.scraper import fetch_reddit_comments
from features.reddit_scraper.preprocess import preprocess_reddit_data
from features.reddit_scraper.summarizer import summarize_places
from base_models import UserRequest

app = FastAPI(title='trip-planner-server')

@app.post('/generate-iternary')
def generate_iternary(user_req: UserRequest):
    try:
        prompt = user_req.prompt
        print(f'Generating Iternary for prompt: {prompt}')
        parsed = llm_parse_user_input(prompt)
        print("Parsed Input:", parsed)
        que =  generate_clarifying_questions(parsed)
        if len(que):
            print('Need More clarification from user')
            resp = ' '.join(que)
            return JSONResponse(
                status_code=200, 
                content={
                    "message": 'Need clarification',
                    "resp": resp
                }
            )
        place = parsed["location"]
        print('Location: ', place)
        posts = fetch_reddit_comments(place, limit=10)
        print("Number of Posts: ", len(posts))
        
        text_blob = preprocess_reddit_data(posts)
        summary = summarize_places(text_blob, place)

        itinerary = generate_itinerary(parsed, summary)
        print("Generated Itinerary:", itinerary)

        personalized = apply_personalization(itinerary, parsed["themes"])
        print("Personalized Itinerary:", personalized)
        
        return JSONResponse(
            status_code=200,
            content=personalized
        )

    except Exception as e:
        print(f'Error while calling generate-iternary api: {e}')
        return JSONResponse(
            status_code=500,
            content={
                'message': 'Failed to Generate Iternary'
            }
        )

@app.post('/generate-final-iternary')
def generate_iternary(user_req: UserRequest):
    try:
        prompt = user_req.prompt
        print(f'Generating final Iternary for prompt: {prompt}')
        parsed = llm_parse_user_input(prompt)
        print("Parsed Input:", parsed)
        place = parsed["location"]
        print('Location: ', place)
        posts = fetch_reddit_comments(place, limit=10)
        print("Number of Posts: ", len(posts))
        
        text_blob = preprocess_reddit_data(posts)
        summary = summarize_places(text_blob, place)

        itinerary = generate_itinerary(parsed, summary)
        print("Generated Itinerary:", itinerary)

        personalized = apply_personalization(itinerary, parsed["themes"])
        print("Personalized Itinerary:", personalized)
        
        return JSONResponse(
            status_code=200,
            content=personalized
        )

    except Exception as e:
        print(f'Error while calling generate-final-iternary api: {e}')
        return JSONResponse(
            status_code=500,
            content={
                'message': 'Failed to Generate Final Iternary'
            }
        )

@app.get('/')
def default_func():
    try:
        return JSONResponse(status_code=200, content={
            "message": "Server is running"
        })
    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse(status_code=400)
