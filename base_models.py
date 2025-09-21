from pydantic import BaseModel
from typing import Optional, Dict, Any, List, Union

class UserRequest(BaseModel):
    prompt: str

class ClarrifyingUserReq(BaseModel):
    prompt: str
    clarrifying_answers: str
    
class StoryTelling(BaseModel):
    iternary: dict

class OptimizeRequest(BaseModel):
    itinerary_json: dict
    parsed_input: dict
    start_day: int = 2
    city: str = "Goa"


class OptimizeResponse(BaseModel):
    iternary: list
    total_estimated_cost: int

class ItineraryRequest(BaseModel):
    start_day: int = 2
    city: str  # single city for the whole trip
    iternary: dict

class HotelSearchRequest(BaseModel):
    city_code: str
    checkin_date: str
    checkout_date: str
    adults: Optional[int] = 1

class FlightSearchRequest(BaseModel):
    origin: str
    destination: str
    departure_date: str
    return_date: Optional[str] = None
    adults: Optional[int] = 1

# Flight related models for booking
class FlightInfo(BaseModel):
    flight_number: str
    airline: str
    origin: str
    destination: str
    departure_time: str
    arrival_time: str
    price: str
    duration: str
    stops: int

class TravelerInfo(BaseModel):
    id: str = "1"
    dateOfBirth: str = "1990-01-01"
    name: Dict[str, str] = {"firstName": "John", "lastName": "Doe"}
    gender: str = "MALE"
    contact: Dict[str, Any] = {
        "emailAddress": "john@example.com",
        "phones": [{"deviceType": "MOBILE", "countryCallingCode": "91", "number": "9999999999"}]
    }
    documents: List[Dict[str, Any]] = [{
        "documentType": "PASSPORT",
        "number": "A12345678",
        "expiryDate": "2030-01-01",
        "issuanceCountry": "IN",
        "nationality": "IN",
        "holder": True
    }]

# Updated to handle the search results format you're sending
class FlightBookingRequest(BaseModel):
    # Handle the "flights" array from search results
    flights: List[FlightInfo]
    traveler_info: Optional[TravelerInfo] = None
    
    # Optional: specify which flight to book (default: first one)
    selected_flight_index: Optional[int] = 0

# Alternative model for single flight booking
class SingleFlightBookingRequest(BaseModel):
    flight_offer: FlightInfo
    traveler_info: Optional[TravelerInfo] = None

# Hotel booking models
class HotelInfo(BaseModel):
    hotel_id: str
    name: str
    location: str
    check_in: str
    check_out: str
    price: str
    rating: float
    amenities: Optional[List[str]] = []
    description: Optional[str] = ""
    images: Optional[List[str]] = []

class GuestInfo(BaseModel):
    id: str = "1"
    firstName: str = "John"
    lastName: str = "Doe"
    email: str = "john@example.com"
    phone: str = "+919999999999"
    address: Optional[Dict[str, str]] = {
        "street": "123 Main St",
        "city": "Mumbai",
        "state": "Maharashtra",
        "country": "India",
        "zipCode": "400001"
    }
    specialRequests: Optional[str] = ""

# Updated to handle hotels array from search results (like flights)
class HotelBookingRequest(BaseModel):
    # Handle the "hotels" array from search results
    hotels: List[HotelInfo]
    guest_info: Optional[GuestInfo] = None
    
    # Optional: specify which hotel to book (default: first one)
    selected_hotel_index: Optional[int] = 0
    
    # Booking details
    rooms: Optional[int] = 1
    adults: Optional[int] = 1
    children: Optional[int] = 0

# Alternative model for single hotel booking
class SingleHotelBookingRequest(BaseModel):
    hotel: HotelInfo
    guest_info: Optional[GuestInfo] = None
    rooms: Optional[int] = 1
    adults: Optional[int] = 1
    children: Optional[int] = 0

# Payment models
class PaymentRequest(BaseModel):
    amount: float
    vendor: str = "general"
    currency: str = "INR"

class PaymentCaptureRequest(BaseModel):
    payment_id: str
    amount: float
    vendor: str = "general"


class Airport(BaseModel):
    iata_code: str
    name: str
    city: str


