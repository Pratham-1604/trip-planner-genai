import datetime
import os
import requests
import time
from dotenv import load_dotenv

load_dotenv()


class EMTService:
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

    # ------------------ TOKEN ------------------
    def get_amadeus_token(self):
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
                print("✅ Amadeus token obtained")
                return token
            else:
                print(f"❌ Token failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Token exception: {e}")
            return None

    # ------------------ HOTEL LIST ------------------
    def search_hotels_by_city(self, city_code, debug=True):
        if self.use_mock:
            return {
                "hotels": [
                    {"hotelId": "MCLONGHM", "name": "Taj Palace", "cityCode": city_code},
                    {"hotelId": "MCLONGOB", "name": "Oberoi", "cityCode": city_code}
                ]
            }

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        url = f"{self.base_url}/v1/reference-data/locations/hotels/by-city"
        headers = {"Authorization": f"Bearer {self.amadeus_token}"}
        params = {"cityCode": city_code}

        if debug:
            print(f"🏨 Getting hotel list for city: {city_code}")

        try:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            if response.status_code == 200:
                data = response.json()
                hotels = data.get("data", [])
                if debug:
                    print(f"✅ Found {len(hotels)} hotels")
                return {"hotels": hotels, "city_code": city_code}
            else:
                return {"error": f"API returned {response.status_code}"}
        except Exception as e:
            return {"error": str(e)}

    # ------------------ HOTEL OFFERS ------------------
    def get_hotel_offers(self, hotel_ids, checkin_date, checkout_date, adults=1, debug=True):
        if self.use_mock:
            offers = []
            for hotel_id in hotel_ids:
                offers.append({
                    "hotelId": hotel_id,
                    "offers": [
                        {"price": {"total": "150.00", "currency": "USD"},
                         "room": {"typeEstimated": {"category": "STANDARD"}}},
                        {"price": {"total": "180.00", "currency": "USD"},
                         "room": {"typeEstimated": {"category": "DELUXE"}}}
                    ],
                    "hotel": {"name": f"Mock Hotel {hotel_id}", "rating": 5, "address": {"line1": "123 Street"}}
                })
            return {"offers": offers}

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        all_offers = []
        for hotel_id in hotel_ids:
            url = f"{self.base_url}/v3/shopping/hotel-offers/by-hotel"
            headers = {"Authorization": f"Bearer {self.amadeus_token}"}
            params = {
                "hotelId": hotel_id,
                "checkInDate": checkin_date,
                "checkOutDate": checkout_date,
                "adults": adults,
                "currency": "USD"
            }
            try:
                response = requests.get(url, headers=headers, params=params, timeout=20)
                if response.status_code == 200:
                    data = response.json()
                    hotel_data = data.get("data", [])
                    if hotel_data:
                        all_offers.append({
                            "hotelId": hotel_id,
                            "hotel": hotel_data[0].get("hotel", {}),
                            "offers": hotel_data[0].get("offers", []),
                            "checkin": checkin_date,
                            "checkout": checkout_date
                        })
                time.sleep(0.5)
            except Exception as e:
                if debug:
                    print(f"❌ Exception for hotel {hotel_id}: {e}")

        return {"offers": all_offers}

    # ------------------ COMPLETE HOTEL SEARCH ------------------
    def search_hotels_complete(self, city_code, checkin_date, checkout_date, adults=1, debug=True):
        if debug:
            print(f"\n🏨 COMPLETE HOTEL SEARCH: {city_code} ({checkin_date} → {checkout_date})")

        hotel_list_result = self.search_hotels_by_city(city_code, debug)
        if "error" in hotel_list_result:
            return hotel_list_result

        hotels = hotel_list_result.get("hotels", [])
        hotel_ids = [h.get("hotelId") for h in hotels if h.get("hotelId")]
        if not hotel_ids:
            return {"error": "No hotel IDs found", "hotels": []}

        offers_result = self.get_hotel_offers(hotel_ids, checkin_date, checkout_date, adults, debug)
        offers = offers_result.get("offers", [])

        final_results = []
        for offer_data in offers:
            hotel_info = offer_data.get("hotel", {})
            hotel_offers = offer_data.get("offers", [])
            if not hotel_offers:
                continue

            best_offer = hotel_offers[0]
            final_results.append({
                "id": offer_data.get("hotelId"),
                "name": hotel_info.get("name", "Unknown Hotel"),
                "location": city_code,
                "price": best_offer.get("price", {}).get("total", "N/A"),
                "currency": best_offer.get("price", {}).get("currency", "USD"),
                "checkin": checkin_date,
                "checkout": checkout_date,
                "room_type": best_offer.get("room", {}).get("typeEstimated", {}).get("category", "N/A"),
                "rating": hotel_info.get("rating"),
                "address": hotel_info.get("address", {}),
                "total_offers": len(hotel_offers),
                "offers": hotel_offers
            })

        if debug:
            print(f"✅ {len(final_results)} hotels with offers found")

        return {
            "hotels": final_results,
            "total_hotels_in_city": len(hotels),
            "hotels_with_offers": len(final_results),
            "city_code": city_code
        }

    # ------------------ FLIGHT SEARCH (ENHANCED) ------------------
    def search_flights_enhanced(self, origin, destination, departure_date, return_date=None, adults=1, debug=True):
        """
        Enhanced flight search with mock support for round-trip flights.
        """
        if self.use_mock:
            flights = [
                {
                    "flight_number": "AI101",
                    "airline": "Air India",
                    "origin": origin,
                    "destination": destination,
                    "departure_time": f"{departure_date}T08:00",
                    "arrival_time": f"{departure_date}T12:00",
                    "price": "₹5000",
                    "duration": "4H",
                    "stops": 0
                },
                {
                    "flight_number": "6E203",
                    "airline": "Indigo",
                    "origin": origin,
                    "destination": destination,
                    "departure_time": f"{departure_date}T09:00",
                    "arrival_time": f"{departure_date}T13:30",
                    "price": "₹4500",
                    "duration": "4H30M",
                    "stops": 0
                }
            ]
            if return_date:
                # add return flights
                flights.extend([
                    {
                        "flight_number": "AI102",
                        "airline": "Air India",
                        "origin": destination,
                        "destination": origin,
                        "departure_time": f"{return_date}T14:00",
                        "arrival_time": f"{return_date}T18:00",
                        "price": "₹5000",
                        "duration": "4H",
                        "stops": 0
                    },
                    {
                        "flight_number": "6E204",
                        "airline": "Indigo",
                        "origin": destination,
                        "destination": origin,
                        "departure_time": f"{return_date}T15:00",
                        "arrival_time": f"{return_date}T19:30",
                        "price": "₹4500",
                        "duration": "4H30M",
                        "stops": 0
                    }
                ])
            return {"flights": flights}

        if not self.amadeus_token:
            return {"error": "No Amadeus token available"}

        url = f"{self.base_url}/v2/shopping/flight-offers"
        headers = {"Authorization": f"Bearer {self.amadeus_token}"}
        params = {
            "originLocationCode": origin,
            "destinationLocationCode": destination,
            "departureDate": departure_date,
            "adults": adults,
            "currencyCode": "USD",
            "max": 10
        }
        if return_date:
            params["returnDate"] = return_date

        for attempt in range(1, 4):
            timeout = 25 + (attempt * 15)
            try:
                response = requests.get(url, headers=headers, params=params, timeout=timeout)
                if response.status_code == 200:
                    flights_data = response.json().get("data", [])
                    flights = self._parse_flight_data(flights_data, origin, destination, departure_date)
                    if debug:
                        print(f"✅ Found {len(flights)} flight offers")
                    return {"flights": flights}
                else:
                    if debug:
                        print(f"❌ API Error {response.status_code}: {response.text}")
            except requests.exceptions.Timeout:
                if debug:
                    print(f"⏰ Timeout attempt {attempt}")
            except Exception as e:
                if debug:
                    print(f"❌ Exception: {e}")
            time.sleep(3)

        return {"error": "Flight search failed after multiple attempts"}

    # Keep original _parse_flight_data
    def _parse_flight_data(self, flights, origin, destination, date):
        simplified = []
        for f in flights:
            try:
                price_info = f.get("price", {})
                itineraries = f.get("itineraries", [])
                if itineraries:
                    outbound = itineraries[0]
                    segments = outbound.get("segments", [])
                    first_seg = segments[0]
                    last_seg = segments[-1]
                    simplified.append({
                        "flight_number": f"{first_seg.get('carrierCode')}{first_seg.get('number')}",
                        "airline": first_seg.get("carrierCode"),
                        "origin": first_seg.get("departure", {}).get("iataCode", origin),
                        "destination": last_seg.get("arrival", {}).get("iataCode", destination),
                        "departure_time": first_seg.get("departure", {}).get("at", ""),
                        "arrival_time": last_seg.get("arrival", {}).get("at", ""),
                        "price": f"{price_info.get('currency')} {price_info.get('total')}",
                        "duration": outbound.get("duration", ""),
                        "stops": len(segments) - 1,
                        "date": date
                    })
            except Exception:
                continue
        return simplified

    # ------------------ PAYMENT ------------------
    def create_payment_order(self, amount_inr, currency="INR"):
        if self.use_mock:
            return {"id": "pay_mock_123", "amount": amount_inr, "currency": currency, "status": "created"}
        url = "https://api.razorpay.com/v1/orders"
        auth = (self.razorpay_key, self.razorpay_secret)
        data = {"amount": amount_inr * 100, "currency": currency, "payment_capture": 1}
        headers = {"Content-Type": "application/json"}
        try:
            response = requests.post(url, auth=auth, json=data, headers=headers)
            return response.json()
        except Exception as e:
            return {"error": str(e)}

    # ------------------ TEST ------------------
    def test_hotel_search(self):
        today = datetime.date.today()
        tomorrow = today + datetime.timedelta(days=1)
        day_after = today + datetime.timedelta(days=2)
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
                print(f"✅ {len(hotels)} hotels with offers")
                for hotel in hotels[:2]:
                    print(f"   🏨 {hotel['name']} - Best Price: {hotel['currency']} {hotel['price']}")
                    print(f"     Total Offers: {hotel['total_offers']}")


if __name__ == "__main__":
    service = EMTService(use_mock=True)
    service.test_hotel_search()
