import datetime
import requests

class EMTBookingServiceMock:
    def __init__(self, config: dict, use_mock=True):
        self.use_mock = use_mock
        self.amadeus_api_key = config.get("amadeus_api_key", "demo-key")
        self.amadeus_api_secret = config.get("amadeus_api_secret", "demo-secret")
        self.expedia_api_key = config.get("expedia_api_key", "demo-expedia")
        self.razorpay_key = config.get("razorpay_key", "demo-razor")
        self.razorpay_secret = config.get("razorpay_secret", "demo-razor-secret")

        self.amadeus_token = None
        if not self.use_mock:
            self.amadeus_token = self.get_amadeus_token()

    # -----------------------------
    # Amadeus Auth
    # -----------------------------
    def get_amadeus_token(self):
        url = "https://test.api.amadeus.com/v1/security/oauth2/token"
        payload = {
            "grant_type": "client_credentials",
            "client_id": self.amadeus_api_key,
            "client_secret": self.amadeus_api_secret,
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        resp = requests.post(url, data=payload, headers=headers)
        return resp.json().get("access_token") if resp.status_code == 200 else None

    # -----------------------------
    # Flights
    # -----------------------------
    def search_flights(self, origin, destination, date):
        if self.use_mock:
            return {
                "flights": [
                    {"airline": "Indigo", "origin": origin, "destination": destination, "date": date, "price": 4500},
                    {"airline": "Air India", "origin": origin, "destination": destination, "date": date, "price": 5200}
                ]
            }
        else:
            url = "https://test.api.amadeus.com/v2/shopping/flight-offers"
            headers = {"Authorization": f"Bearer {self.amadeus_token}"}
            params = {"originLocationCode": origin, "destinationLocationCode": destination,
                      "departureDate": date, "adults": 1, "currencyCode": "INR", "max": 3}
            resp = requests.get(url, headers=headers, params=params)
            return resp.json()

    def book_flight(self, flight):
        if self.use_mock:
            return {"booking_id": "flt123", "status": "confirmed", "flight": flight}
        else:
            url = "https://test.api.amadeus.com/v1/booking/flight-orders"
            headers = {"Authorization": f"Bearer {self.amadeus_token}", "Content-Type": "application/json"}
            payload = {"data": flight}
            resp = requests.post(url, headers=headers, json=payload)
            return resp.json()

    # -----------------------------
    # Hotels
    # -----------------------------
    def search_hotels(self, location, checkin, checkout):
        if self.use_mock:
            return {
                "hotels": [
                    {"name": "Taj Palace", "location": location, "checkin": checkin, "checkout": checkout, "price": 7000},
                    {"name": "Oberoi", "location": location, "checkin": checkin, "checkout": checkout, "price": 6500}
                ]
            }
        else:
            url = "https://hotels4.p.rapidapi.com/locations/v3/search"
            headers = {"X-RapidAPI-Key": self.expedia_api_key, "X-RapidAPI-Host": "hotels4.p.rapidapi.com"}
            params = {"q": location}
            resp = requests.get(url, headers=headers, params=params)
            return resp.json()

    def book_hotel(self, hotel):
        if self.use_mock:
            return {"booking_id": "htl123", "status": "confirmed", "hotel": hotel}
        else:
            raise NotImplementedError("Expedia/Booking.com booking requires partner contract")

    # -----------------------------
    # Activities
    # -----------------------------
    def search_activities(self, location, date):
        if self.use_mock:
            return {
                "activities": [
                    {"name": "City Tour", "location": location, "date": date, "price": 2000},
                    {"name": "Food Walk", "location": location, "date": date, "price": 1500}
                ]
            }
        else:
            url = "https://test.api.amadeus.com/v1/shopping/activities"
            headers = {"Authorization": f"Bearer {self.amadeus_token}"}
            params = {"latitude": "28.6139", "longitude": "77.2090", "startDate": date, "endDate": date}
            resp = requests.get(url, headers=headers, params=params)
            return resp.json()

    def book_activity(self, activity):
        if self.use_mock:
            return {"booking_id": "act123", "status": "confirmed", "activity": activity}
        else:
            url = "https://test.api.amadeus.com/v1/booking/activity-orders"
            headers = {"Authorization": f"Bearer {self.amadeus_token}", "Content-Type": "application/json"}
            payload = {"data": activity}
            resp = requests.post(url, headers=headers, json=payload)
            return resp.json()

    # -----------------------------
    # Payments
    # -----------------------------
    def create_payment_order(self, amount_inr, currency="INR"):
        if self.use_mock:
            return {"id": "pay_mock_123", "amount": amount_inr, "currency": currency, "status": "created"}
        else:
            url = "https://api.razorpay.com/v1/orders"
            payload = {"amount": amount_inr * 100, "currency": currency, "payment_capture": 1}
            resp = requests.post(url, auth=(self.razorpay_key, self.razorpay_secret), json=payload)
            return resp.json()
