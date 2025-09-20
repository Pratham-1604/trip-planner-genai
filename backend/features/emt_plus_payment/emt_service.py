import datetime
import os
import requests
import time
from dotenv import load_dotenv

load_dotenv()

import datetime
import os
import requests
import time
from dotenv import load_dotenv

load_dotenv()

class EMTServiceCorrected:
    def __init__(self, use_mock=True):
        self.use_mock = use_mock
        self.amadeus_api_key = os.getenv("AMADEUS_API_KEY")
        self.amadeus_api_secret = os.getenv("AMADEUS_API_SECRET")
        self.razorpay_key = os.getenv("RAZORPAY_KEY")
        self.razorpay_secret = os.getenv("RAZORPAY_SECRET")
        
        self.base_url = "https://test.api.amadeus.com"
        self.amadeus_token = None
        
        if not self.use_mock:
            self.amadeus_token = self.get_amadeus_token()

    def get_amadeus_token(self):
        """Get Amadeus authentication token"""
        url = f"{self.base_url}/v1/security/oauth2/token"
        payload = {
            "grant_type": "client_credentials",
            "client_id": self.amadeus_api_key,
            "client_secret": self.amadeus_api_secret,
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        try:
            response = requests.post(url, data=payload, headers=headers, timeout=30)
            if response.status_code == 200:
                token = response.json().get("access_token")
                print("✅ Amadeus access token obtained")
                return token
            else:
                print(f"❌ Token failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Token exception: {e}")
            return None

    def search_hotels_by_city(self, city_code, debug=True):
        """
        Step 1: Get list of hotels in a city using the Hotel List API
        Endpoint: /v1/reference-data/locations/hotels/by-city
        """
        if self.use_mock:
            return {
                "hotels": [
                    {"hotelId": "MCLONGHM", "name": "Taj Palace", "cityCode": city_code},
                    {"hotelId": "MCLONGOB", "name": "Oberoi", "cityCode": city_code}
                ]
            }

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        # Use the correct Hotel List endpoint
        url = f"{self.base_url}/v1/reference-data/locations/hotels/by-city"
        headers = {"Authorization": f"Bearer {self.amadeus_token}"}
        params = {"cityCode": city_code}

        if debug:
            print(f"🏨 Step 1: Getting hotel list for city: {city_code}")
            print(f"🔗 URL: {url}")
            print(f"📋 Params: {params}")

        try:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            
            if debug:
                print(f"📊 Response Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                hotels = data.get("data", [])
                
                if debug:
                    print(f"✅ Found {len(hotels)} hotels in {city_code}")
                    if hotels:
                        print(f"📋 Sample hotels:")
                        for hotel in hotels[:10]:  # Show first 3
                            print(f"   - {hotel.get('name', 'Unknown')} (ID: {hotel.get('hotelId', 'N/A')})")
                
                return {"hotels": hotels, "city_code": city_code}
                
            elif response.status_code == 404:
                if debug:
                    print(f"❌ City code '{city_code}' not found")
                return {"error": f"City code '{city_code}' not found", "hotels": []}
            else:
                error_text = response.text[:200] if response.text else "Unknown error"
                if debug:
                    print(f"❌ API Error {response.status_code}: {error_text}")
                return {"error": f"API returned {response.status_code}", "details": error_text}
                
        except requests.exceptions.Timeout:
            return {"error": "Hotel list request timed out"}
        except Exception as e:
            if debug:
                print(f"❌ Exception: {e}")
            return {"error": str(e)}

    def search_hotels_by_geocode(self, latitude, longitude, radius=5, debug=True):
        """
        Alternative: Search hotels by geographic coordinates
        Endpoint: /v1/reference-data/locations/hotels/by-geocode
        """
        if self.use_mock:
            return {
                "hotels": [
                    {"hotelId": "MOCK001", "name": "Mock Hotel 1", "latitude": latitude, "longitude": longitude},
                    {"hotelId": "MOCK002", "name": "Mock Hotel 2", "latitude": latitude, "longitude": longitude}
                ]
            }

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        url = f"{self.base_url}/v1/reference-data/locations/hotels/by-geocode"
        headers = {"Authorization": f"Bearer {self.amadeus_token}"}
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius  # radius in KM
        }

        if debug:
            print(f"🗺️ Searching hotels by geocode: ({latitude}, {longitude})")
            print(f"📏 Radius: {radius} km")

        try:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            
            if debug:
                print(f"📊 Response Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                hotels = data.get("data", [])
                
                if debug:
                    print(f"✅ Found {len(hotels)} hotels within {radius}km")
                
                return {"hotels": hotels}
            else:
                return {"error": f"Geocode search failed: {response.status_code}"}
                
        except Exception as e:
            return {"error": str(e)}

    def get_hotel_offers(self, hotel_ids, checkin_date, checkout_date, adults=1, debug=True):
        """
        Step 2: Get hotel offers for specific hotels
        Endpoint: /v2/shopping/hotel-offers/by-hotel
        """
        if self.use_mock:
            offers = []
            for hotel_id in hotel_ids[:2]:  # Mock first 2
                offers.append({
                    "hotelId": hotel_id,
                    "offers": [{
                        "price": {"total": "150.00", "currency": "USD"},
                        "room": {"typeEstimated": {"category": "STANDARD"}}
                    }]
                })
            return {"offers": offers}

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        all_offers = []
        
        # The API allows checking multiple hotels, but let's do them individually for better error handling
        for hotel_id in hotel_ids[:5]:  # Limit to first 5 hotels
            url = f"{self.base_url}/v3/shopping/hotel-offers/by-hotel"
            headers = {"Authorization": f"Bearer {self.amadeus_token}"}
            params = {
                "hotelId": hotel_id,
                "checkInDate": checkin_date,
                "checkOutDate": checkout_date,
                "adults": adults,
                "currency": "USD"
            }

            if debug:
                print(f"💰 Getting offers for hotel: {hotel_id}")

            try:
                response = requests.get(url, headers=headers, params=params, timeout=20)
                
                if response.status_code == 200:
                    data = response.json()
                    hotel_data = data.get("data", [])
                    
                    if hotel_data:
                        hotel_offer = hotel_data[0]  # Should be one hotel
                        offers = hotel_offer.get("offers", [])
                        
                        if offers:
                            all_offers.append({
                                "hotelId": hotel_id,
                                "hotel": hotel_offer.get("hotel", {}),
                                "offers": offers,
                                "checkin": checkin_date,
                                "checkout": checkout_date
                            })
                            
                            if debug:
                                best_offer = offers[0]
                                price = best_offer.get("price", {})
                                print(f"   ✅ Found offers - Best: {price.get('currency')} {price.get('total')}")
                        else:
                            if debug:
                                print(f"   ⚠️ No offers available")
                    else:
                        if debug:
                            print(f"   ⚠️ No data returned")
                            
                elif response.status_code == 404:
                    if debug:
                        print(f"   ❌ Hotel {hotel_id} not found or no offers")
                else:
                    if debug:
                        print(f"   ❌ Error {response.status_code} for hotel {hotel_id}")
                        
            except requests.exceptions.Timeout:
                if debug:
                    print(f"   ⏰ Timeout getting offers for {hotel_id}")
            except Exception as e:
                if debug:
                    print(f"   ❌ Exception for {hotel_id}: {e}")
            
            time.sleep(0.5)  # Rate limiting between requests

        return {"offers": all_offers}

    def search_hotels_complete(self, city_code, checkin_date, checkout_date, adults=1, debug=True):
        """
        Complete hotel search workflow:
        1. Get hotel list by city
        2. Get offers for available hotels
        """
        if debug:
            print(f"\n🏨 COMPLETE HOTEL SEARCH FOR {city_code}")
            print(f"📅 {checkin_date} → {checkout_date}, Adults: {adults}")
            print("="*50)

        # Step 1: Get hotel list
        hotel_list_result = self.search_hotels_by_city(city_code, debug)
        
        if "error" in hotel_list_result:
            return hotel_list_result
            
        hotels = hotel_list_result.get("hotels", [])
        
        if not hotels:
            return {"error": f"No hotels found in city {city_code}", "hotels": []}
        
        # Extract hotel IDs
        hotel_ids = [hotel.get("hotelId") for hotel in hotels if hotel.get("hotelId")]
        
        if not hotel_ids:
            return {"error": "No valid hotel IDs found", "hotels": []}
        
        if debug:
            print(f"\n🎯 Step 2: Getting offers for {len(hotel_ids)} hotels...")
        
        # Step 2: Get offers
        offers_result = self.get_hotel_offers(hotel_ids, checkin_date, checkout_date, adults, debug)
        
        if "error" in offers_result:
            return offers_result
        
        # Combine hotel info with offers
        final_results = []
        offers = offers_result.get("offers", [])
        
        for offer_data in offers:
            hotel_info = offer_data.get("hotel", {})
            hotel_offers = offer_data.get("offers", [])
            
            if hotel_offers:
                best_offer = hotel_offers[0]  # Take first/best offer
                price_info = best_offer.get("price", {})
                room_info = best_offer.get("room", {})
                
                final_results.append({
                    "id": offer_data.get("hotelId"),
                    "name": hotel_info.get("name", "Unknown Hotel"),
                    "location": city_code,
                    "price": price_info.get("total", "N/A"),
                    "currency": price_info.get("currency", "USD"),
                    "checkin": checkin_date,
                    "checkout": checkout_date,
                    "room_type": room_info.get("typeEstimated", {}).get("category", "N/A"),
                    "rating": hotel_info.get("rating"),
                    "address": hotel_info.get("address", {}),
                    "total_offers": len(hotel_offers)
                })
        
        if debug:
            print(f"\n✅ FINAL RESULT: {len(final_results)} hotels with offers")
        
        return {
            "hotels": final_results,
            "total_hotels_in_city": len(hotels),
            "hotels_with_offers": len(final_results),
            "city_code": city_code
        }

    def search_flights(self, origin, destination, date, return_date=None, adults=1):
        """Flight search with improved timeout handling"""
        if self.use_mock:
            return {
                "flights": [
                    {"airline": "Indigo", "origin": origin, "destination": destination, "date": date, "price": "₹4500"},
                    {"airline": "Air India", "origin": origin, "destination": destination, "date": date, "price": "₹5200"}
                ]
            }
        
        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        url = f"{self.base_url}/v2/shopping/flight-offers"
        headers = {"Authorization": f"Bearer {self.amadeus_token}"}
        
        params = {
            "originLocationCode": origin,
            "destinationLocationCode": destination,
            "departureDate": date,
            "adults": adults,
            "currencyCode": "USD",
            "max": 5
        }
        
        if return_date:
            params["returnDate"] = return_date
            
        print(f"🛫 Searching flights: {origin} → {destination} on {date}")
        
        # Retry with increasing timeouts
        for attempt in range(1, 4):
            timeout = 25 + (attempt * 15)  # 40s, 55s, 70s
            
            print(f"   Attempt {attempt}/3 (timeout: {timeout}s)")
            
            try:
                response = requests.get(url, headers=headers, params=params, timeout=timeout)
                
                if response.status_code == 200:
                    data = response.json()
                    flights = data.get("data", [])
                    
                    print(f"   ✅ Found {len(flights)} flights")
                    return {"flights": self._parse_flight_data(flights, origin, destination, date)}
                else:
                    print(f"   ❌ Status {response.status_code}")
                    if attempt == 3:
                        return {"error": f"API returned {response.status_code}"}
                        
            except requests.exceptions.Timeout:
                print(f"   ⏰ Timeout after {timeout}s")
                if attempt == 3:
                    return {"error": "Flight search timed out after multiple attempts"}
            except Exception as e:
                return {"error": str(e)}
                
            time.sleep(3)  # Wait before retry
        
        return {"error": "All flight search attempts failed"}

    def _parse_flight_data(self, flights, origin, destination, date):
        """Helper method to parse flight data"""
        simplified_flights = []
        
        for flight in flights:
            try:
                price_info = flight.get("price", {})
                itineraries = flight.get("itineraries", [])
                
                if itineraries:
                    outbound = itineraries[0]
                    segments = outbound.get("segments", [])
                    
                    if segments:
                        first_segment = segments[0]
                        last_segment = segments[-1]
                        
                        simplified_flights.append({
                            "flight_number": f"{first_segment.get('carrierCode')}{first_segment.get('number')}",
                            "airline": first_segment.get("carrierCode"),
                            "origin": first_segment.get("departure", {}).get("iataCode", origin),
                            "destination": last_segment.get("arrival", {}).get("iataCode", destination),
                            "departure_time": first_segment.get("departure", {}).get("at", ""),
                            "arrival_time": last_segment.get("arrival", {}).get("at", ""),
                            "price": f"{price_info.get('currency')} {price_info.get('total')}",
                            "duration": outbound.get("duration", ""),
                            "stops": len(segments) - 1,
                            "date": date
                        })
            except Exception as e:
                print(f"⚠️ Error parsing flight: {e}")
                continue
        
        return simplified_flights

    def create_payment_order(self, amount_inr, currency="INR"):
        """Payment order creation"""
        if self.use_mock:
            return {"id": "pay_mock_123", "amount": amount_inr, "currency": currency, "status": "created"}
        else:
            url = "https://api.razorpay.com/v1/orders"
            auth = (self.razorpay_key, self.razorpay_secret)
            data = {"amount": amount_inr * 100, "currency": currency, "payment_capture": 1}
            headers = {"Content-Type": "application/json"}
            try:
                response = requests.post(url, auth=auth, json=data, headers=headers)
                return response.json()
            except Exception as e:
                return {"error": str(e)}

    def test_hotel_search(self):
        """Test the corrected hotel search"""
        print("🧪 TESTING CORRECTED HOTEL SEARCH")
        print("="*50)
        
        today = datetime.date.today()
        tomorrow = today + datetime.timedelta(days=1)
        day_after = today + datetime.timedelta(days=2)
        
        # Test different city codes
        # test_cities = ["NYC", "LON", "PAR", "BOM", "DEL"]
        test_cities = ["NYC"]
        
        for city in test_cities:
            print(f"\n📍 Testing city: {city}")
            result = self.search_hotels_complete(
                city_code=city,
                checkin_date=str(tomorrow),
                checkout_date=str(day_after),
                adults=1,
                debug=True
            )
            
            if "error" in result:
                print(f"❌ Error: {result['error']}")
            else:
                hotels = result.get("hotels", [])
                print(f"✅ Success: {len(hotels)} hotels with offers")
                
                for hotel in hotels[:2]:  # Show first 2
                    print(f"   🏨 {hotel['name']}: {hotel['currency']} {hotel['price']}")
            
            print("-" * 30)


# Test the corrected service
if __name__ == "__main__":
    service = EMTServiceCorrected(use_mock=False)
    
    # Test individual components
    print("1️⃣ Testing Hotel List API...")
    hotel_list = service.search_hotels_by_city("NYC", debug=True)
    print(f"Result: {len(hotel_list.get('hotels', []))} hotels found")
    
    print("\n2️⃣ Testing Complete Hotel Search...")
    today = datetime.date.today()
    tomorrow = today + datetime.timedelta(days=1)
    day_after = today + datetime.timedelta(days=2)
    
    complete_result = service.search_hotels_complete(
        city_code="NYC",
        checkin_date=str(tomorrow),
        checkout_date=str(day_after),
        adults=1,
        debug=True
    )
    
    print(f"\nFinal result: {len(complete_result.get('hotels', []))} hotels with offers")
    
    # Test full suite
    print("\n3️⃣ Running Full Test Suite...")
    service.test_hotel_search()

# Test the corrected service
if __name__ == "__main__":
    service = EMTServiceCorrected(use_mock=False)
    
    # Test individual components
    print("1️⃣ Testing Hotel List API...")
    hotel_list = service.search_hotels_by_city("NYC", debug=True)
    print(f"Result: {len(hotel_list.get('hotels', []))} hotels found")
    
    print("\n2️⃣ Testing Complete Hotel Search...")
    today = datetime.date.today()
    tomorrow = today + datetime.timedelta(days=1)
    day_after = today + datetime.timedelta(days=2)
    
    complete_result = service.search_hotels_complete(
        city_code="NYC",
        checkin_date=str(tomorrow),
        checkout_date=str(day_after),
        adults=1,
        debug=True
    )
    
    print(f"\nFinal result: {len(complete_result.get('hotels', []))} hotels with offers")
    
    # Test full suite
    print("\n3️⃣ Running Full Test Suite...")
    service.test_hotel_search()