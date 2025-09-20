from pydantic import BaseModel
from typing import Optional

class UserRequest(BaseModel):
    prompt: str

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

class ClarrifyingUserReq(BaseModel):
    prompt: str
    clarrifying_answers: str
    
class StoryTelling(BaseModel):
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

class ClarrifyingUserReq(BaseModel):
    prompt: str
    clarrifying_answers: str
    
class StoryTelling(BaseModel):
    iternary: dict