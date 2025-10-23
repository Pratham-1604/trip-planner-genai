# GenAI Exchange - Travel Planner

> **A travel planning application that generates itineraries using AI and integrates with booking services.**

## Project Overview

This project was built for the **GenAI Exchange Hackathon**. It's a travel planning tool that helps users create itineraries and book flights/hotels.

### What it does
- Generates travel itineraries based on user input
- Searches and books flights and hotels
- Integrates with Reddit for travel recommendations
- Provides basic optimization features

---

## Tech Stack

### Backend
- FastAPI (Python web framework)
- Google Gemini AI for itinerary generation
- Reddit API for travel recommendations
- Amadeus API for flight/hotel search
- Razorpay for payments

### Frontend
- Flutter mobile app
- Firebase for authentication
- Google Maps integration

---

## Features

### Itinerary Generation
- Parse user travel requests using AI
- Ask clarifying questions when needed
- Generate day-by-day travel plans
- Include Reddit recommendations

### Booking System
- Search for flights and hotels
- Book flights and hotels
- Process payments through Razorpay

### Basic Optimization
- Weather-based suggestions
- Simple cost optimization
- Basic route planning

### Mobile App
- Flutter-based mobile interface
- Firebase authentication
- Google Maps integration

---

## Project Structure

```
GenAi-Exchange-Google-backend/
├── main.py                          # FastAPI server
├── base_models.py                   # API data models
├── llm_client.py                    # Google Gemini client
├── requirements.txt                 # Dependencies
│
├── features/
│   ├── iternary_generation/         # Itinerary creation
│   ├── reddit_scraper/             # Reddit integration
│   ├── emt_plus_payment/           # Booking system
│   ├── predictive_pipeline/        # Basic optimization
│   ├── maps_scrapper/              # Maps integration
│   └── weather/                    # Weather services
│
└── google_frontend/                # Flutter app
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    └── pubspec.yaml
```

---

## Setup

### Prerequisites
- Python 3.11+
- Flutter SDK
- API keys for Google, Reddit, Amadeus, and Razorpay

### Backend Setup

1. Clone and install dependencies:
```bash
git clone <repository-url>
cd GenAi-Exchange-Google-backend
pip install -r requirements.txt
```

2. Create `.env` file with your API keys:
```env
GOOGLE_API_KEY=your_key
REDDIT_CLIENT_ID=your_id
REDDIT_CLIENT_SECRET=your_secret
AMADEUS_API_KEY=your_key
AMADEUS_API_SECRET=your_secret
RAZORPAY_KEY=your_key
RAZORPAY_SECRET=your_secret
```

3. Run the server:
```bash
python main.py
```

### Frontend Setup

1. Navigate to Flutter app:
```bash
cd google_frontend
flutter pub get
```

2. Configure Firebase and run:
```bash
flutter run
```

---

## API Endpoints

### Main Endpoints

- `POST /generate-iternary` - Generate travel itinerary
- `GET /search-flights` - Search for flights
- `GET /search-hotels` - Search for hotels
- `POST /book-flights` - Book flights
- `POST /book-hotels` - Book hotels
- `POST /optimize-itinerary` - Optimize existing itinerary

### API Documentation
Visit `http://localhost:8000/docs` for interactive API documentation.

---

## How it works

1. User enters travel request (e.g., "5 days in Goa, budget ₹50,000")
2. System asks clarifying questions if needed
3. AI generates itinerary using Google Gemini
4. Reddit data provides local recommendations
5. User can search and book flights/hotels
6. Basic optimization adjusts plans based on weather

---

## Deployment

### Backend
```bash
# Deploy to Heroku
heroku create your-app-name
git push heroku main
```

### Frontend
```bash
# Build Flutter app
flutter build apk --release
```

---

## License

MIT License
