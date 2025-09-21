import requests
from dotenv import load_dotenv
import os
import uuid

load_dotenv()

class EMTBooking:
    def __init__(self, amadeus_token=None, razorpay_key=None, razorpay_secret=None, use_mock=False):
        self.use_mock = use_mock
        self.amadeus_token = amadeus_token or os.getenv("AMADEUS_TOKEN")
        self.razorpay_key = razorpay_key or os.getenv("RAZORPAY_KEY")
        self.razorpay_secret = razorpay_secret or os.getenv("RAZORPAY_SECRET")
        self.base_url = "https://test.api.amadeus.com"
        
        # Initialize token if credentials are available
        client_id = os.getenv("AMADEUS_CLIENT_ID")
        client_secret = os.getenv("AMADEUS_CLIENT_SECRET")
        if client_id and client_secret and not self.amadeus_token:
            self.get_amadeus_token(client_id, client_secret)

    # -----------------------------
    # Authentication
    # -----------------------------
    def get_amadeus_token(self, client_id, client_secret):
        """Get Amadeus access token"""
        if self.use_mock:
            self.amadeus_token = "mock_token_12345"
            return True
            
        url = f"{self.base_url}/v1/security/oauth2/token"
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        data = {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret
        }
        
        try:
            response = requests.post(url, headers=headers, data=data)
            if response.status_code == 200:
                self.amadeus_token = response.json()["access_token"]
                return True
            else:
                print(f"Token request failed: {response.status_code}, {response.text}")
                return False
        except Exception as e:
            print(f"Token request exception: {e}")
            return False

    # -----------------------------
    # Flight Operations (Amadeus)
    # -----------------------------
    def search_flights_amadeus(self, origin, destination, departure_date, adults=1):
        """Search flights using Amadeus Flight Offers Search API"""
        if self.use_mock:
            return self._mock_flight_search_response(origin, destination, departure_date, adults)
            
        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}
            
        url = f"{self.base_url}/v2/shopping/flight-offers"
        headers = {
            "Authorization": f"Bearer {self.amadeus_token}",
            "Content-Type": "application/json"
        }
        
        params = {
            "originLocationCode": origin,
            "destinationLocationCode": destination,
            "departureDate": departure_date,
            "adults": adults
        }
        
        try:
            response = requests.get(url, headers=headers, params=params)
            return response.json()
        except Exception as e:
            return {"error": f"Flight search failed: {str(e)}"}

    def price_flight_offers(self, flight_offers):
        """Confirm flight pricing using Flight Offers Price API"""
        if self.use_mock:
            return {
                "data": {
                    "type": "flight-offers-pricing",
                    "flightOffers": flight_offers
                }
            }
            
        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}
            
        url = f"{self.base_url}/v1/shopping/flight-offers/pricing"
        headers = {
            "Authorization": f"Bearer {self.amadeus_token}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "data": {
                "type": "flight-offers-pricing",
                "flightOffers": flight_offers
            }
        }
        
        try:
            response = requests.post(url, headers=headers, json=payload)
            return response.json()
        except Exception as e:
            return {"error": f"Flight pricing failed: {str(e)}"}

    def book_flight(self, flight_offer, traveler_info=None):
        """Book flight using Amadeus Flight Create Orders API"""
        if self.use_mock:
            return {
                "data": {
                    "type": "flight-order",
                    "id": f"MOCK_BOOKING_{uuid.uuid4().hex[:8].upper()}",
                    "queuingOfficeId": "NCE1A0955",
                    "associatedRecords": [
                        {
                            "reference": f"MOCK{uuid.uuid4().hex[:6].upper()}",
                            "creationDate": "2025-09-21T10:30:00.000+00:00"
                        }
                    ],
                    "flightOffers": [flight_offer],
                    "travelers": [traveler_info or self._get_default_traveler()],
                    "bookingStatus": "confirmed"
                }
            }
            
        if not self.amadeus_token:
            return {"error": "No Amadeus token available for booking"}

        url = f"{self.base_url}/v1/booking/flight-orders"
        headers = {
            "Authorization": f"Bearer {self.amadeus_token}",
            "Content-Type": "application/json"
        }

        # Use default traveler info if not provided
        if traveler_info is None:
            traveler_info = self._get_default_traveler()

        # Convert traveler_info if it's a Pydantic model
        if hasattr(traveler_info, 'dict'):
            traveler_info = traveler_info.dict()

        payload = {
            "data": {
                "type": "flight-order",
                "flightOffers": [flight_offer],
                "travelers": [traveler_info]
            }
        }

        try:
            response = requests.post(url, headers=headers, json=payload)
            return response.json()
        except Exception as e:
            return {"error": f"Booking request failed: {str(e)}"}

    # -----------------------------
    # Utility Functions
    # -----------------------------
    def convert_custom_to_amadeus_search_params(self, flights_data):
        """Convert your custom flight format to Amadeus search parameters"""
        if not flights_data or len(flights_data) == 0:
            return None
            
        first_flight = flights_data[0]
        
        # Extract date from departure_time (assuming ISO format)
        departure_date = first_flight["departure_time"].split("T")[0]
        
        return {
            "origin": first_flight["origin"],
            "destination": first_flight["destination"],
            "departure_date": departure_date,
            "adults": 1
        }

    def convert_to_amadeus_format(self, flight):
        """Convert custom flight format to Amadeus flight offer format"""
        # Handle both dict and Pydantic model
        if hasattr(flight, 'dict'):
            flight = flight.dict()
            
        return {
            "type": "flight-offer",
            "id": "1",
            "source": "GDS",
            "instantTicketingRequired": False,
            "nonHomogeneous": False,
            "oneWay": False,
            "lastTicketingDate": "2025-09-24",
            "numberOfBookableSeats": 5,
            "price": {
                "currency": "INR",
                "total": flight["price"].replace("₹", ""),
                "base": flight["price"].replace("₹", ""),
                "fees": [{"amount": "0", "type": "SUPPLIER"}],
                "grandTotal": flight["price"].replace("₹", "")
            },
            "pricingOptions": {
                "fareType": ["PUBLISHED"],
                "includedCheckedBagsOnly": True
            },
            "validatingAirlineCodes": [flight["airline"][:2]],
            "itineraries": [{
                "duration": flight["duration"],
                "segments": [{
                    "departure": {
                        "iataCode": flight["origin"],
                        "at": flight["departure_time"] + ":00" if not flight["departure_time"].endswith(":00") else flight["departure_time"]
                    },
                    "arrival": {
                        "iataCode": flight["destination"],
                        "at": flight["arrival_time"] + ":00" if not flight["arrival_time"].endswith(":00") else flight["arrival_time"]
                    },
                    "carrierCode": flight["airline"][:2],
                    "number": flight["flight_number"],
                    "aircraft": {"code": "320"},
                    "operating": {"carrierCode": flight["airline"][:2]},
                    "duration": flight["duration"],
                    "id": "1",
                    "numberOfStops": flight["stops"],
                    "blacklistedInEU": False
                }]
            }],
            "travelerPricings": [{
                "travelerId": "1",
                "fareOption": "STANDARD",
                "travelerType": "ADULT",
                "price": {
                    "currency": "INR",
                    "total": flight["price"].replace("₹", ""),
                    "base": flight["price"].replace("₹", "")
                },
                "fareDetailsBySegment": [{
                    "segmentId": "1",
                    "cabin": "ECONOMY",
                    "fareBasis": "UU1YXII",
                    "class": "U",
                    "includedCheckedBags": {"quantity": 1}
                }]
            }]
        }

    def _get_default_traveler(self):
        """Get default traveler information"""
        return {
            "id": "1",
            "dateOfBirth": "1990-01-01",
            "name": {"firstName": "John", "lastName": "Doe"},
            "gender": "MALE",
            "contact": {
                "emailAddress": "john@example.com",
                "phones": [{"deviceType": "MOBILE", "countryCallingCode": "91", "number": "9999999999"}]
            },
            "documents": [{
                "documentType": "PASSPORT",
                "number": "A12345678",
                "expiryDate": "2030-01-01",
                "issuanceCountry": "IN",
                "nationality": "IN",
                "holder": True
            }]
        }

    def _mock_flight_search_response(self, origin, destination, departure_date, adults):
        """Generate mock flight search response"""
        return {
            "meta": {"count": 2, "links": {"self": "https://test.api.amadeus.com/v2/shopping/flight-offers"}},
            "data": [
                {
                    "type": "flight-offer",
                    "id": "1",
                    "source": "GDS",
                    "instantTicketingRequired": False,
                    "nonHomogeneous": False,
                    "oneWay": False,
                    "lastTicketingDate": "2025-09-24",
                    "numberOfBookableSeats": 5,
                    "itineraries": [{
                        "duration": "PT4H",
                        "segments": [{
                            "departure": {
                                "iataCode": origin,
                                "at": f"{departure_date}T08:00:00"
                            },
                            "arrival": {
                                "iataCode": destination,
                                "at": f"{departure_date}T12:00:00"
                            },
                            "carrierCode": "AI",
                            "number": "101",
                            "aircraft": {"code": "320"},
                            "operating": {"carrierCode": "AI"},
                            "duration": "PT4H",
                            "id": "1",
                            "numberOfStops": 0,
                            "blacklistedInEU": False
                        }]
                    }],
                    "price": {
                        "currency": "INR",
                        "total": "5000",
                        "base": "4500",
                        "fees": [{"amount": "500", "type": "SUPPLIER"}],
                        "grandTotal": "5000"
                    },
                    "pricingOptions": {
                        "fareType": ["PUBLISHED"],
                        "includedCheckedBagsOnly": True
                    },
                    "validatingAirlineCodes": ["AI"],
                    "travelerPricings": [{
                        "travelerId": "1",
                        "fareOption": "STANDARD",
                        "travelerType": "ADULT",
                        "price": {
                            "currency": "INR",
                            "total": "5000",
                            "base": "4500"
                        },
                        "fareDetailsBySegment": [{
                            "segmentId": "1",
                            "cabin": "ECONOMY",
                            "fareBasis": "UU1YXII",
                            "class": "U",
                            "includedCheckedBags": {"quantity": 1}
                        }]
                    }]
                }
            ]
        }

    # -----------------------------
    # Hotel Booking
    # -----------------------------
    def book_hotel(self, hotel):
        """Book hotel - placeholder for real hotel API integration"""
        return {
            "status": "booked_mock" if self.use_mock else "booked_real", 
            "hotel": hotel,
            "booking_reference": f"HTL_{uuid.uuid4().hex[:8].upper()}"
        }

    # -----------------------------
    # Payment Operations (Razorpay)
    # -----------------------------
    def create_order(self, amount_inr, vendor="general"):
        """Create a Razorpay order for a specific vendor (flight/hotel)"""
        if self.use_mock:
            return {
                "status": "order_created_mock", 
                "amount": amount_inr, 
                "vendor": vendor, 
                "id": f"order_{vendor}_{uuid.uuid4().hex[:8]}"
            }

        if not self.razorpay_key or not self.razorpay_secret:
            return {"error": "Razorpay credentials not available"}

        url = "https://api.razorpay.com/v1/orders"
        data = {
            "amount": int(amount_inr * 100),  # amount in paise
            "currency": "INR",
            "payment_capture": 1,
            "notes": {"vendor": vendor}
        }

        try:
            resp = requests.post(url, auth=(self.razorpay_key, self.razorpay_secret), json=data)
            result = resp.json()
            result["vendor"] = vendor
            return result
        except Exception as e:
            return {"error": f"Order creation failed: {str(e)}"}

    def capture_payment(self, payment_id, amount_inr, vendor="general"):
        """Capture a payment by payment_id and attach vendor info"""
        if self.use_mock:
            return {
                "status": "captured_mock", 
                "payment_id": payment_id, 
                "vendor": vendor, 
                "amount": amount_inr
            }

        if not self.razorpay_key or not self.razorpay_secret:
            return {"error": "Razorpay credentials not available"}

        url = f"https://api.razorpay.com/v1/payments/{payment_id}/capture"
        data = {"amount": int(amount_inr * 100), "currency": "INR"}
        
        try:
            resp = requests.post(url, auth=(self.razorpay_key, self.razorpay_secret), data=data)
            result = resp.json()
            result["vendor"] = vendor
            return result
        except Exception as e:
            return {"error": f"Payment capture failed: {str(e)}"}

    def verify_payment(self, razorpay_order_id, razorpay_payment_id, razorpay_signature):
        """Verify payment signature for security"""
        import hmac
        import hashlib
        
        if self.use_mock:
            return {"status": "verified_mock"}

        if not self.razorpay_secret:
            return {"error": "Razorpay secret not available"}