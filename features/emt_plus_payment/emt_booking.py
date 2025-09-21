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
    def search_hotels_amadeus(self, city_code, checkin_date, checkout_date, adults=1, rooms=1):
        """Search hotels using Amadeus Hotel Search API"""
        if self.use_mock:
            return self._mock_hotel_search_response(city_code, checkin_date, checkout_date, adults, rooms)
            
        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}
            
        url = f"{self.base_url}/v3/shopping/hotel-offers"
        headers = {
            "Authorization": f"Bearer {self.amadeus_token}",
            "Content-Type": "application/json"
        }
        
        params = {
            "cityCode": city_code,
            "checkInDate": checkin_date,
            "checkOutDate": checkout_date,
            "adults": adults,
            "roomQuantity": rooms
        }
        
        try:
            response = requests.get(url, headers=headers, params=params)
            return response.json()
        except Exception as e:
            return {"error": f"Hotel search failed: {str(e)}"}

    def book_hotel(self, hotel_offer, guest_info=None, rooms=1, adults=1):
        """Book hotel using Amadeus Hotel Booking API or mock booking"""
        if self.use_mock:
            return {
                "data": {
                    "type": "hotel-order",
                    "id": f"MOCK_HOTEL_BOOKING_{uuid.uuid4().hex[:8].upper()}",
                    "providerConfirmationId": f"HTL{uuid.uuid4().hex[:6].upper()}",
                    "hotelOffers": [hotel_offer],
                    "guests": [guest_info or self._get_default_guest()],
                    "bookingStatus": "confirmed",
                    "totalPrice": hotel_offer.get("price", "₹0"),
                    "checkIn": hotel_offer.get("check_in"),
                    "checkOut": hotel_offer.get("check_out"),
                    "rooms": rooms,
                    "adults": adults
                }
            }
        
        # For real hotel booking, you would integrate with:
        # 1. Amadeus Hotel Booking API
        # 2. Booking.com API
        # 3. Expedia API, etc.
        
        return {
            "status": "booked_real", 
            "hotel": hotel_offer,
            "booking_reference": f"HTL_{uuid.uuid4().hex[:8].upper()}",
            "message": "Real hotel booking API integration needed"
        }

    def convert_custom_to_hotel_search_params(self, hotels_data):
        """Convert custom hotel format to search parameters"""
        if not hotels_data or len(hotels_data) == 0:
            return None
            
        first_hotel = hotels_data[0]
        
        return {
            "city_code": self._extract_city_code_from_location(first_hotel.get("location", "")),
            "checkin_date": first_hotel.get("check_in", ""),
            "checkout_date": first_hotel.get("check_out", ""),
            "adults": 1
        }

    def convert_to_hotel_amadeus_format(self, hotel):
        """Convert custom hotel format to Amadeus hotel offer format"""
        if hasattr(hotel, 'dict'):
            hotel = hotel.dict()
            
        return {
            "type": "hotel-offer",
            "id": hotel.get("hotel_id", "1"),
            "checkInDate": hotel.get("check_in", ""),
            "checkOutDate": hotel.get("check_out", ""),
            "rateCode": "RAC",
            "rateFamilyEstimated": {
                "code": "PRO",
                "type": "P"
            },
            "room": {
                "type": "A1K",
                "typeEstimated": {
                    "category": "SUPERIOR_ROOM",
                    "beds": 1,
                    "bedType": "KING"
                },
                "description": {
                    "text": "Standard Room"
                }
            },
            "guests": {
                "adults": 1
            },
            "price": {
                "currency": "INR",
                "base": hotel.get("price", "₹0").replace("₹", ""),
                "total": hotel.get("price", "₹0").replace("₹", ""),
                "variations": {
                    "average": {
                        "base": hotel.get("price", "₹0").replace("₹", "")
                    }
                }
            },
            "policies": {
                "paymentType": "guarantee",
                "cancellation": {
                    "description": {
                        "text": "Free cancellation before check-in"
                    }
                }
            },
            "hotel": {
                "type": "hotel",
                "hotelId": hotel.get("hotel_id", ""),
                "name": hotel.get("name", ""),
                "rating": hotel.get("rating", 0),
                "cityCode": self._extract_city_code_from_location(hotel.get("location", "")),
                "latitude": 0.0,
                "longitude": 0.0,
                "address": {
                    "lines": [hotel.get("location", "")],
                    "cityName": hotel.get("location", ""),
                    "countryCode": "IN"
                },
                "amenities": hotel.get("amenities", [])
            }
        }

    def _get_default_guest(self):
        """Get default guest information"""
        return {
            "id": "1",
            "firstName": "John",
            "lastName": "Doe",
            "email": "john@example.com",
            "phone": "+919999999999",
            "address": {
                "street": "123 Main St",
                "city": "Mumbai",
                "state": "Maharashtra",
                "country": "India",
                "zipCode": "400001"
            }
        }

    def _extract_city_code_from_location(self, location):
        """Extract city code from location string - simplified implementation"""
        city_codes = {
            "mumbai": "BOM",
            "delhi": "DEL", 
            "bangalore": "BLR",
            "chennai": "MAA",
            "kolkata": "CCU",
            "hyderabad": "HYD",
            "pune": "PNQ",
            "goa": "GOI"
        }
        
        location_lower = location.lower()
        for city, code in city_codes.items():
            if city in location_lower:
                return code
        
        # Default fallback
        return "BOM"

    def _mock_hotel_search_response(self, city_code, checkin_date, checkout_date, adults, rooms):
        """Generate mock hotel search response"""
        return {
            "meta": {"count": 3},
            "data": [
                {
                    "type": "hotel-offer",
                    "id": "1",
                    "checkInDate": checkin_date,
                    "checkOutDate": checkout_date,
                    "hotel": {
                        "type": "hotel",
                        "hotelId": "HTL001",
                        "name": f"Grand Hotel {city_code}",
                        "rating": 4.5,
                        "cityCode": city_code,
                        "address": {
                            "lines": [f"123 Main Street, {city_code}"],
                            "cityName": city_code,
                            "countryCode": "IN"
                        },
                        "amenities": ["WiFi", "Pool", "Gym", "Restaurant", "Spa"]
                    },
                    "price": {
                        "currency": "INR",
                        "base": "5000",
                        "total": "5900",
                        "variations": {
                            "average": {"base": "5000"}
                        }
                    },
                    "room": {
                        "type": "A1K",
                        "typeEstimated": {
                            "category": "SUPERIOR_ROOM",
                            "beds": 1,
                            "bedType": "KING"
                        }
                    },
                    "guests": {"adults": adults}
                },
                {
                    "type": "hotel-offer",
                    "id": "2", 
                    "checkInDate": checkin_date,
                    "checkOutDate": checkout_date,
                    "hotel": {
                        "type": "hotel",
                        "hotelId": "HTL002",
                        "name": f"Luxury Resort {city_code}",
                        "rating": 4.8,
                        "cityCode": city_code,
                        "address": {
                            "lines": [f"456 Beach Road, {city_code}"],
                            "cityName": city_code,
                            "countryCode": "IN"
                        },
                        "amenities": ["WiFi", "Pool", "Spa", "Beach Access", "Restaurant", "Bar"]
                    },
                    "price": {
                        "currency": "INR",
                        "base": "8000",
                        "total": "9440",
                        "variations": {
                            "average": {"base": "8000"}
                        }
                    },
                    "room": {
                        "type": "A2Q",
                        "typeEstimated": {
                            "category": "DELUXE_ROOM",
                            "beds": 2,
                            "bedType": "QUEEN"
                        }
                    },
                    "guests": {"adults": adults}
                }
            ]
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

        try:
            # Create signature
            payload = f"{razorpay_order_id}|{razorpay_payment_id}"
            expected_signature = hmac.new(
                self.razorpay_secret.encode(),
                payload.encode(),
                hashlib.sha256
            ).hexdigest()
            
            if expected_signature == razorpay_signature:
                return {"status": "verified"}
            else:
                return {"error": "Payment signature verification failed"}
        except Exception as e:
            return {"error": f"Payment verification failed: {str(e)}"}

    # -----------------------------
    # Health Check
    # -----------------------------
    def health_check(self):
        """Check service health and configuration"""
        return {
            "amadeus_token_available": bool(self.amadeus_token),
            "razorpay_configured": bool(self.razorpay_key and self.razorpay_secret),
            "mock_mode": self.use_mock,
            "base_url": self.base_url
        }