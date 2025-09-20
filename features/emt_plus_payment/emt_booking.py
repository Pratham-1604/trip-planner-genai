import requests
from dotenv import load_dotenv
import os
import uuid

load_dotenv()  # Load API keys


class EMTBooking:
    def __init__(self, amadeus_token=None, razorpay_key=None, razorpay_secret=None, use_mock=True):
        self.use_mock = use_mock
        self.amadeus_token = amadeus_token
        self.razorpay_key = razorpay_key or os.getenv("RAZORPAY_KEY")
        self.razorpay_secret = razorpay_secret or os.getenv("RAZORPAY_SECRET")

    # -----------------------------
    # Flight Booking (Amadeus)
    # -----------------------------
    def book_flight(self, flight_offer, traveler_info=None):
        if self.use_mock:
            return {"status": "booked_mock", "details": flight_offer}

        if not self.amadeus_token:
            return {"error": "No Amadeus token available for booking"}

        url = "https://test.api.amadeus.com/v1/booking/flight-orders"
        headers = {
            "Authorization": f"Bearer {self.amadeus_token}",
            "Content-Type": "application/json"
        }

        # Default traveler info if not provided
        if traveler_info is None:
            traveler_info = {
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

        payload = {
            "data": {
                "type": "flight-order",
                "flightOffers": [flight_offer],
                "travelers": [traveler_info]
            }
        }

        resp = requests.post(url, headers=headers, json=payload)
        return resp.json()

    # -----------------------------
    # Hotel Booking (Mocked/Real placeholder)
    # -----------------------------
    def book_hotel(self, hotel):
        if self.use_mock:
            return {"status": "booked_mock", "hotel": hotel}
        else:
            # integrate real hotel API if available
            return {"status": "booked_real", "hotel": hotel}

   # -----------------------------
    # Create Razorpay Order
    # -----------------------------
    def create_order(self, amount_inr, vendor="general"):
        """
        Create a Razorpay order for a specific vendor (flight/hotel)
        """
        if self.use_mock:
            return {"status": "order_created_mock", "amount": amount_inr, "vendor": vendor, "id": f"order_{vendor}_mock"}

        url = "https://api.razorpay.com/v1/orders"
        data = {
            "amount": int(amount_inr * 100),  # amount in paise
            "currency": "INR",
            "payment_capture": 1,
            "notes": {"vendor": vendor}
        }

        resp = requests.post(url, auth=(self.razorpay_key, self.razorpay_secret), json=data)
        result = resp.json()
        result["vendor"] = vendor
        return result

    # -----------------------------
    # Capture Razorpay Payment
    # -----------------------------
    def capture_payment(self, payment_id, amount_inr, vendor="general"):
        """
        Capture a payment by payment_id and attach vendor info
        """
        if self.use_mock:
            return {"status": "captured_mock", "payment_id": payment_id, "vendor": vendor, "amount": amount_inr}

        url = f"https://api.razorpay.com/v1/payments/{payment_id}/capture"
        data = {"amount": int(amount_inr * 100), "currency": "INR"}
        resp = requests.post(url, auth=(self.razorpay_key, self.razorpay_secret), data=data)

        result = resp.json()
        result["vendor"] = vendor
        return result