from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi import HTTPException

# Import your existing features
from features.itinerary_generation.llm_parser import llm_parse_user_input, generate_clarifying_questions
from features.itinerary_generation.itinerary_generator import generate_itinerary
from features.itinerary_generation.basic_tag_personalization import apply_personalization
from features.reddit_scraper.scraper import fetch_reddit_comments
from features.reddit_scraper.preprocess import preprocess_reddit_data
from features.reddit_scraper.summarizer import summarize_places
from features.emt_plus_payment.emt_service import EMTService
from features.emt_plus_payment.emt_booking import EMTBooking
from features.itinerary_generation.basic_visualization_generation import visualization_generation, add_images_to_itinerary
from features.predictive_pipeline.weather_optimizer import optimize_itinerary
from data import INDIAN_AIRPORTS
# Import models from base_models
from base_models import (
    UserRequest,
    ClarrifyingUserReq,
    StoryTelling,
    FlightBookingRequest,
    SingleFlightBookingRequest,
    HotelBookingRequest,
    SingleHotelBookingRequest,
    FlightInfo,
    TravelerInfo,
    HotelInfo,
    GuestInfo,
    ItineraryRequest,
    OptimizeRequest,
    OptimizeResponse,
    Airport
)





app = FastAPI(title='trip-planner-server')

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Your existing routes remain the same...
@app.post('/generate-iternary')
def generate_iternary(user_req: UserRequest):
    try:
        prompt = user_req.prompt
        print(f'Generating Iternary for prompt: {prompt}')
        parsed = llm_parse_user_input(prompt)
        print("Parsed Input:", parsed)
        que = generate_clarifying_questions(parsed)
        if len(que):
            print('Need More clarification from user')
            que = [' • ' + q for q in que]
            resp = '\n'.join(que)
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


@app.get("/airports/india")
def get_indian_airports():
    """
    Returns a list of major airports in India (mock data)
    """
    return INDIAN_AIRPORTS


@app.post('/generate-final-iternary')
def generate_final_iternary(user_req: ClarrifyingUserReq):
    try:
        prompt = user_req.prompt
        clarrifying_ans = user_req.clarrifying_answers
        prompt = prompt + ' Clarrifications: ' + clarrifying_ans
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

@app.post("/generate-visual-storytelling")
def get_story_telling(input_data: StoryTelling):
    try:
        iternary = input_data.iternary
        resp = visualization_generation(iternary)
        
        # Step 2: Add real images to each place
        resp_with_images = add_images_to_itinerary(resp)
        
        return JSONResponse(
            status_code=200,
            content=resp_with_images
        )

    except Exception as e:
        print(f'Error while calling generate-visual-storytelling api: {e}')
        return JSONResponse(
            status_code=500,
            content={
                'message': 'Failed to Generate Visual Story'
            }
        )

     

# Initialize services
service = EMTService(use_mock=True)
booking_service = EMTBooking(use_mock=True)

@app.get("/search-hotels")
def search_hotels(
    city: str = Query(..., description="IATA city code e.g., NYC, LON, BOM"),
    checkin: str = Query(..., description="Check-in date (YYYY-MM-DD)"),
    checkout: str = Query(..., description="Check-out date (YYYY-MM-DD)"),
    adults: int = Query(1, description="Number of adults")
):
    try:
        # Use your existing service for now, but format response consistently
        result = service.search_hotels_complete(
            city_code=city,
            checkin_date=checkin,
            checkout_date=checkout,
            adults=adults,
            debug=True
        )
        
        # If your service returns different format, you might want to standardize it
        # to match the expected format for booking:
        if isinstance(result, dict) and "hotels" not in result:
            # Transform to consistent format if needed
            formatted_result = {
                "hotels": [
                    {
                        "hotel_id": "HTL001",
                        "name": "Sample Hotel 1",
                        "location": city,
                        "check_in": checkin,
                        "check_out": checkout,
                        "price": "₹5000",
                        "rating": 4.5,
                        "amenities": ["WiFi", "Pool", "Breakfast"]
                    },
                    {
                        "hotel_id": "HTL002", 
                        "name": "Sample Hotel 2",
                        "location": city,
                        "check_in": checkin,
                        "check_out": checkout,
                        "price": "₹7500",
                        "rating": 4.8,
                        "amenities": ["WiFi", "Spa", "Gym", "Restaurant"]
                    }
                ]
            }
            return JSONResponse(content=formatted_result)
        
        return result
    except Exception as e:
        return {"error": str(e)}

@app.get("/search-flights")
def search_flights(
    origin: str = Query(..., description="Origin IATA code"),
    destination: str = Query(..., description="Destination IATA code"),
    departure_date: str = Query(..., description="Departure date YYYY-MM-DD"),
    return_date: str = Query(None, description="Return/arrival date YYYY-MM-DD"),
    adults: int = Query(1, description="Number of adults")
):
    """Enhanced flight search API that supports both departure and return dates."""
    result = service.search_flights_enhanced(
        origin=origin,
        destination=destination,
        departure_date=departure_date,
        return_date=return_date,
        adults=adults
    )
    return JSONResponse(content=result)

# Updated booking endpoint to handle search results format
@app.post("/book-flights")
def book_flight(req: FlightBookingRequest):
    """
    Book flights from search results.
    Accepts the "flights" array format from your search-flights endpoint.
    Books the first flight by default, or specify selected_flight_index.
    """
    try:
        # Validate that we have flights
        if not req.flights or len(req.flights) == 0:
            return JSONResponse(
                status_code=400,
                content={"error": "No flights provided in the request"}
            )

        # Select which flight to book (default: first one)
        flight_index = req.selected_flight_index if req.selected_flight_index is not None else 0
        
        if flight_index >= len(req.flights):
            return JSONResponse(
                status_code=400,
                content={"error": f"Invalid flight index {flight_index}. Available flights: {len(req.flights)}"}
            )

        selected_flight = req.flights[flight_index]
        print(f"Booking flight {flight_index + 1} of {len(req.flights)}: {selected_flight.flight_number}")

        # Convert to Amadeus format
        amadeus_offer = booking_service.convert_to_amadeus_format(selected_flight)
        
        # Book the flight
        traveler_data = req.traveler_info.dict() if req.traveler_info else None
        booking_resp = booking_service.book_flight(amadeus_offer, traveler_data)
        
        # Add metadata about which flight was booked
        if "data" in booking_resp:
            booking_resp["data"]["selected_flight_info"] = {
                "flight_number": selected_flight.flight_number,
                "airline": selected_flight.airline,
                "route": f"{selected_flight.origin} -> {selected_flight.destination}",
                "departure_time": selected_flight.departure_time,
                "price": selected_flight.price
            }
        
        return JSONResponse(content=booking_resp)
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

# Hotel booking endpoints (similar pattern to flights)
@app.post("/book-hotels")
def book_hotel(req: HotelBookingRequest):
    """
    Book hotels from search results.
    Accepts the "hotels" array format from your search-hotels endpoint.
    Books the first hotel by default, or specify selected_hotel_index.
    """
    try:
        # Validate that we have hotels
        if not req.hotels or len(req.hotels) == 0:
            return JSONResponse(
                status_code=400,
                content={"error": "No hotels provided in the request"}
            )

        # Select which hotel to book (default: first one)
        hotel_index = req.selected_hotel_index if req.selected_hotel_index is not None else 0
        
        if hotel_index >= len(req.hotels):
            return JSONResponse(
                status_code=400,
                content={"error": f"Invalid hotel index {hotel_index}. Available hotels: {len(req.hotels)}"}
            )

        selected_hotel = req.hotels[hotel_index]
        print(f"Booking hotel {hotel_index + 1} of {len(req.hotels)}: {selected_hotel.name}")

        # Convert to Amadeus format
        amadeus_hotel_offer = booking_service.convert_to_hotel_amadeus_format(selected_hotel)
        
        # Book the hotel
        guest_data = req.guest_info.dict() if req.guest_info else None
        booking_resp = booking_service.book_hotel(
            amadeus_hotel_offer, 
            guest_data, 
            req.rooms, 
            req.adults
        )
        
        # Add metadata about which hotel was booked
        if "data" in booking_resp:
            booking_resp["data"]["selected_hotel_info"] = {
                "hotel_name": selected_hotel.name,
                "location": selected_hotel.location,
                "check_in": selected_hotel.check_in,
                "check_out": selected_hotel.check_out,
                "price": selected_hotel.price,
                "rating": selected_hotel.rating,
                "rooms": req.rooms,
                "adults": req.adults
            }
        
        return JSONResponse(content=booking_resp)
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

@app.post("/book-single-hotel")
def book_single_hotel(req: SingleHotelBookingRequest):
    """
    Book a single hotel using the hotel format.
    """
    try:
        # Convert to Amadeus format
        amadeus_offer = booking_service.convert_to_hotel_amadeus_format(req.hotel)
        
        # Book the hotel
        guest_data = req.guest_info.dict() if req.guest_info else None
        booking_resp = booking_service.book_hotel(
            amadeus_offer, 
            guest_data, 
            req.rooms, 
            req.adults
        )
        
        return JSONResponse(content=booking_resp)
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

# Alternative endpoint for single flight booking
@app.post("/book-single-flight")
def book_single_flight(req: SingleFlightBookingRequest):
    """
    Book a single flight using the flight_offer format.
    """
    try:
        # Convert to Amadeus format
        amadeus_offer = booking_service.convert_to_amadeus_format(req.flight_offer)
        
        # Book the flight
        traveler_data = req.traveler_info.dict() if req.traveler_info else None
        booking_resp = booking_service.book_flight(amadeus_offer, traveler_data)
        
        return JSONResponse(content=booking_resp)
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

# For backward compatibility and testing
@app.post("/book-flights-search-workflow")
def book_flights_search_workflow(req: FlightBookingRequest):
    """
    Alternative workflow: Search -> Price -> Book using Amadeus APIs.
    This uses the first flight from your request to search for real flights.
    """
    try:
        if not req.flights or len(req.flights) == 0:
            return JSONResponse(
                status_code=400,
                content={"error": "No flights provided"}
            )

        # Use first flight for search parameters
        first_flight = req.flights[0]
        flight_data = first_flight.dict()
        search_params = booking_service.convert_custom_to_amadeus_search_params([flight_data])
        
        if not search_params:
            return JSONResponse(
                status_code=400,
                content={"error": "Invalid flight data for search"}
            )

        # Step 1: Search flights using Amadeus API
        search_result = booking_service.search_flights_amadeus(
            search_params["origin"],
            search_params["destination"],
            search_params["departure_date"],
            search_params["adults"]
        )

        if "error" in search_result:
            return JSONResponse(content=search_result)

        flight_offers = search_result.get("data", [])
        if not flight_offers:
            return JSONResponse(
                status_code=404,
                content={"error": "No flights found"}
            )

        # Step 2: Price the offers
        price_result = booking_service.price_flight_offers(flight_offers)
        if "error" in price_result:
            return JSONResponse(content=price_result)
        
        priced_offers = price_result.get("data", {}).get("flightOffers", [])

        # Step 3: Book the first offer
        if priced_offers:
            traveler_data = req.traveler_info.dict() if req.traveler_info else None
            booking_resp = booking_service.book_flight(priced_offers[0], traveler_data)
            return JSONResponse(content=booking_resp)
        else:
            return JSONResponse(
                status_code=404,
                content={"error": "No bookable flights found"}
            )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": f"Search and booking failed: {str(e)}"}
        )


@app.post("/optimize-itinerary")
def optimize_itinerary_api(req: OptimizeRequest):
    try:
        resp = optimize_itinerary(
            itinerary_json=req.itinerary_json,
            parsed_input=req.parsed_input,
            start_day=req.start_day,
            city=req.city
        
        )
        print("Optimized Itinerary:", resp)
        return JSONResponse(
            status_code = 200,
            content = {
                "message": "Optimized Iternary",
                "response": resp
            }
        )
    except Exception as e:
        print(f"Error while optimizing iternary: {e}")
        return JSONResponse(
            status_code = 500,
            content = {
                "message": "Failed to optimize iternary",
                "response": req.itinerary_json
    }
    )

@app.get('/health')
def health_check():
    """Health check endpoint"""
    try:
        booking_health = booking_service.health_check()
        return JSONResponse(status_code=200, content={
            "message": "Server is running",
            "booking_service": booking_health
        })
    except Exception as e:
        print(f"Health check error: {e}")
        return JSONResponse(status_code=503, content={"error": str(e)})



@app.get('/')
def default_func():
    try:
        return JSONResponse(status_code=200, content={
            "message": "Trip Planner Server is running",
            "endpoints": {
                "generate_itinerary": "/generate-iternary",
                "search_flights": "/search-flights",
                "book_flights": "/book-flights (accepts flights array)",
                "book_single_flight": "/book-single-flight (accepts single flight_offer)",
                "search_hotels": "/search-hotels",
                "book_hotels": "/book-hotels (accepts hotels array)",
                "book_single_hotel": "/book-single-hotel (accepts single hotel)",
                "health": "/health"
            },
            "usage": {
                "book_flights": "Send the exact JSON from search-flights endpoint",
                "book_hotels": "Send hotels array similar to flights format",
                "selected_index": "Optional: specify which flight/hotel to book (default: 0)"
            },
            "examples": {
                "hotel_search_response": {
                    "hotels": [
                        {
                            "hotel_id": "HTL001",
                            "name": "Grand Hotel",
                            "location": "Mumbai",
                            "check_in": "2025-09-25",
                            "check_out": "2025-09-27",
                            "price": "₹5000",
                            "rating": 4.5,
                            "amenities": ["WiFi", "Pool", "Gym"]
                        }
                    ]
                },
                "hotel_booking_request": {
                    "hotels": "array_from_search_hotels",
                    "selected_hotel_index": 0,
                    "guest_info": {
                        "firstName": "John",
                        "lastName": "Doe",
                        "email": "john@example.com"
                    },
                    "rooms": 1,
                    "adults": 2
                }
            }
        })
    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse(status_code=400, content={"error": str(e)})