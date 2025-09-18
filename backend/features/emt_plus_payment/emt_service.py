import datetime
import os
import requests
from dotenv import load_dotenv

load_dotenv()  # Load .env variables

class EMTServiceMock:
    def __init__(self, use_mock=True):
        self.use_mock = use_mock

        # Load API keys from environment variables
        self.amadeus_api_key = os.getenv("AMADEUS_API_KEY")
        self.amadeus_api_secret = os.getenv("AMADEUS_API_SECRET")
        self.razorpay_key = os.getenv("RAZORPAY_KEY")
        self.razorpay_secret = os.getenv("RAZORPAY_SECRET")

         
        # For real API usage, get Amadeus token
        self.amadeus_token = None
        if not self.use_mock:
            self.amadeus_token = self.get_amadeus_token()

    # -----------------------------
    # Amadeus Authentication
    # -----------------------------
    def get_amadeus_token(self):
        url = "https://test.api.amadeus.com/v1/security/oauth2/token"
        payload = {
            "grant_type": "client_credentials",
            "client_id": self.amadeus_api_key,
            "client_secret": self.amadeus_api_secret,
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        try:
            resp = requests.post(url, data=payload, headers=headers)
            if resp.status_code == 200:
                token = resp.json().get("access_token")
                print("✅ Amadeus access token obtained")
                return token
            else:
                print("❌ Failed to get token:", resp.text)
                return None
        except Exception as e:
            print("❌ Exception getting Amadeus token:", e)
            return None

    # -----------------------------
    # Amadeus Flights
    # -----------------------------
    def search_flights(self, origin, destination, date):
        if self.use_mock:
            return {
                "flights": [
                    {"airline": "Indigo", "origin": origin, "destination": destination, "date": date, "price": "₹4500"},
                    {"airline": "Air India", "origin": origin, "destination": destination, "date": date, "price": "₹5200"}
                ]
            }
        else:
            if not self.amadeus_token:
                return {"error": "No Amadeus token available"}

            url = "https://test.api.amadeus.com/v2/shopping/flight-offers"
            headers = {"Authorization": f"Bearer {self.amadeus_token}"}
            params = {
                "originLocationCode": origin,
                "destinationLocationCode": destination,
                "departureDate": date,
                "adults": 1,
                "currencyCode": "INR",
                "max": 3
            }
            try:
                response = requests.get(url, headers=headers, params=params)
                return response.json()
            except Exception as e:
                return {"error": str(e)}

    # -----------------------------
    # Hotels (Mocked) since expedia needs sometime for this 
    # -----------------------------
    def search_hotels(self, location, checkin, checkout):
        return {
            "hotels": [
                {"name": "Taj Palace", "location": location, "checkin": checkin, "checkout": checkout, "price": "₹7000"},
                {"name": "Oberoi", "location": location, "checkin": checkin, "checkout": checkout, "price": "₹6500"},
                {"name": "Marriott", "location": location, "checkin": checkin, "checkout": checkout, "price": "₹6000"}
            ]
        }

    # -----------------------------
    # Razorpay Payments
    # -----------------------------
    def create_payment_order(self, amount_inr, currency="INR"):
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

    # -----------------------------
    # Materialize Trip
    # -----------------------------
    def materialize_trip(self, itinerary_json):
        confirmations = []
        today = datetime.date.today()

        for day in itinerary_json["itinerary"]:
        # Flights only on Day 1
          if day["day"] == 1:
            flights_data = self.search_flights("BOM", "DEL", str(today + datetime.timedelta(days=1)))
            
            # Wrap real API data under 'flights' key
            confirmations.append({
                "type": "flight",
                "details": {
                    "flights": flights_data.get("flights") or flights_data.get("data")
                }
            })

            # Hotels per day
            hotels = self.search_hotels(
                itinerary_json.get("location", "Delhi"),
                str(today + datetime.timedelta(days=day["day"])),
                str(today + datetime.timedelta(days=day["day"] + 1))
            )
            confirmations.append({"type": "hotel", "details": hotels})

        # Payment
        payment = self.create_payment_order(itinerary_json["total_estimated_cost"])
        confirmations.append({"type": "payment", "details": payment})

        return confirmations
