import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_request.dart';
import '../models/itinerary.dart';
import '../config/app_config.dart';

class TripRepository {
  // Use the backend URL from environment variables
  String get _baseUrl => AppConfig.backendApiUrl;

  // Get itinerary - returns either clarification request OR itinerary
  Future<Map<String, dynamic>> getItinerary(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-iternary'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'prompt': userInput}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print(
          'Get itinerary API call failed with status: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        // Fall back to sample data if API fails
        return _getSampleItineraryData(userInput);
      }
    } catch (apiError) {
      print('Get itinerary API call error: $apiError');
      // Fall back to sample data if API is not available
      return _getSampleItineraryData(userInput);
    }
  }

  // Get final itinerary - called only when clarification is needed
  Future<Itinerary> getFinalItinerary(
    String userInput,
    String clarificationAnswers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-final-iternary'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'prompt': userInput,
          'clarrifying_answers': clarificationAnswers,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Itinerary.fromJson(data);
      } else {
        print(
          'Get final itinerary API call failed with status: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        // Fall back to sample data if API fails
        return _getSampleItinerary(userInput);
      }
    } catch (apiError) {
      print('Get final itinerary API call error: $apiError');
      // Fall back to sample data if API is not available
      return _getSampleItinerary(userInput);
    }
  }

  // Helper method to get sample itinerary data
  Map<String, dynamic> _getSampleItineraryData(String userInput) {
    return {
      "itinerary": [
        {
          "day": 1,
          "morning":
              "Arrival at Goa Airport (GOI). Pick up a pre-booked self-drive car from a reputable service like Vailankanni Car Rentals or MyChoize (approx. ₹1500-2000/day for a compact car). Drive to North Goa and check into a hotel in Anjuna or Vagator (e.g., W Goa, The Park Calangute, or a well-rated boutique hotel matching the budget). Relax and freshen up. For breakfast, head to Artjuna Cafe in Assagao for a delicious vegetarian breakfast spread amidst a bohemian ambiance (estimated cost for breakfast: ₹800).",
          "afternoon":
              "Explore the vibrant Anjuna Flea Market (open on Wednesdays, if applicable for your December trip – confirm exact operating days closer to the date). Haggle for souvenirs, clothes, and handicrafts. Enjoy street food snacks like 'Ros Omelette' (vegetarian option available) from local stalls (estimated cost for market and snacks: ₹1500). Later, relax at Anjuna Beach, soaking in the sun and enjoying the lively atmosphere.",
          "evening":
              "Experience North Goa's famous nightlife. Start with dinner at Como Pizzeria for excellent vegetarian pizzas and Italian fare (estimated cost: ₹2000). Afterwards, head to Curlies Beach Shack or Shiva Valley (confirm current opening status closer to your travel date as some venues change) on Anjuna Beach for trance music and lively party vibes. Enjoy drinks and dance the night away (estimated cost for drinks and entry: ₹4000).",
          "estimated_cost": 10300,
        },
        {
          "day": 2,
          "morning":
              "Start the day with a visit to the Chapora Fort for panoramic views of Vagator Beach and the Morjim coastline – perfect for photos. Grab a quick vegetarian breakfast at a local cafe near Vagator (e.g., German Bakery, known for veg options; estimated cost: ₹600).",
          "afternoon":
              "Head to Mandrem Beach for a more relaxed vibe. Enjoy a leisurely vegetarian lunch at one of the peaceful beach shacks (estimated cost: ₹1500). Afterwards, consider a kayaking session (pre-book if possible, estimated cost: ₹1000 per person) or simply relax by the serene waters.",
          "evening":
              "Explore the sophisticated nightlife of North Goa. Enjoy a delectable vegetarian dinner at Olive Bar & Kitchen in Vagator, known for its Mediterranean cuisine and stunning sunset views (estimated cost: ₹3500). Later, head to Tito's Lane in Baga for a classic Goa clubbing experience. Options like Cafe Mambo or Club Titos offer mainstream music and a lively crowd (estimated cost for drinks and entry: ₹3000).",
          "estimated_cost": 9600,
        },
        {
          "day": 3,
          "morning":
              "Drive to Old Goa to immerse yourselves in its rich history and architecture. Visit the Basilica of Bom Jesus and Se Cathedral. Have a light vegetarian breakfast at a local eatery in Old Goa (estimated cost: ₹500).",
          "afternoon":
              "Continue exploring Old Goa, perhaps visiting the Church of St. Cajetan or the Museum of Christian Art. For lunch, try a local vegetarian thali at a simple yet authentic restaurant in the area (estimated cost: ₹1000). Afterwards, drive back towards the central part of Goa.",
          "evening":
              "Experience a different side of Goan entertainment with an evening at a casino. Head to Deltin Jaqk for a fun-filled night of gaming and entertainment (entry packages often include food and drinks; estimated cost: ₹3000 per person, so ₹6000 for a couple). Enjoy the buffet dinner and try your luck at the tables.",
          "estimated_cost": 7500,
        },
        {
          "day": 4,
          "morning":
              "Embark on a scenic drive to South Goa. Check into a hotel near Palolem or Agonda Beach (e.g., Agonda Serenity Resort or a similar beachfront property within budget). Enjoy a peaceful vegetarian breakfast at your hotel or a nearby cafe (estimated cost: ₹800).",
          "afternoon":
              "Spend the afternoon relaxing on the beautiful Palolem Beach. Enjoy swimming, sunbathing, or take a boat trip to Butterfly Beach (if available and weather permits; estimated cost: ₹1500 for the boat trip). For lunch, enjoy fresh vegetarian dishes at Cheeky Chilli in Palolem (estimated cost: ₹1500).",
          "evening":
              "Experience the laid-back yet vibrant nightlife of South Goa. Enjoy a romantic candle-lit vegetarian dinner right on Palolem Beach at one of the many shacks (inquire with your hotel or a specific shack a day in advance for arrangements; estimated cost: ₹3000). After dinner, enjoy live music or a fire show if available, savoring cocktails by the sea (estimated cost for drinks: ₹2000).",
          "estimated_cost": 8800,
        },
        {
          "day": 5,
          "morning":
              "Enjoy a final leisurely vegetarian breakfast in South Goa (estimated cost: ₹700). Depending on your flight schedule, you could visit another serene beach like Cola Beach (be mindful of the driving conditions, especially if it's off-road) or Majorda Beach for a final glimpse of Goa's natural beauty.",
          "afternoon":
              "Begin your journey back to Goa Airport. Stop for a quick vegetarian lunch at a well-rated restaurant en route, or pack some snacks (estimated cost: ₹1000). Return your rental car at the airport.",
          "evening":
              "Depart from Goa Airport (GOI) with wonderful memories of your food and nightlife adventure.",
          "estimated_cost": 1700,
        },
      ],
      "total_estimated_cost": 37900,
    };
  }

  // Generate storytelling experience
  Future<Map<String, dynamic>> generateStorytelling(Itinerary itinerary) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-visual-storytelling'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'iternary': itinerary.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print(
          'Generate storytelling API call failed with status: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        // Fall back to sample data if API fails
        return _getSampleStorytellingData();
      }
    } catch (apiError) {
      print('Generate storytelling API call error: $apiError');
      // Fall back to sample data if API is not available
      return _getSampleStorytellingData();
    }
  }

  // Sample storytelling data for fallback
  Map<String, dynamic> _getSampleStorytellingData() {
    return {
      'story':
          "Welcome to Goa, where sun-kissed beaches meet ancient history and the nights throb with an electrifying rhythm! This 5-day adventure is crafted for those who seek the perfect blend of vibrant nightlife, culinary delights, and serene coastal beauty.",
      'days': [
        {
          'day': 1,
          'title': "North Goa's Bohemian Rhapsody & Trance Nights",
          'summary':
              "Our Goan adventure kicks off in the bohemian heart of North Goa. After settling into our vibrant surroundings, we'll dive into the eclectic Anjuna Flea Market, haggle for treasures, and fuel up on local snacks.",
          'places': [
            {
              'id': 'GOI-arrival',
              'name': 'Goa International Airport (GOI)',
              'description':
                  'The gateway to your Goan escapade. Collect your self-drive car here, your chariot for exploring the coastal wonders.',
              'latitude': 15.267,
              'longitude': 73.8327,
              'imageUrl':
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Goa_International_Airport.jpg/1280px-Goa_International_Airport.jpg',
              'category': 'Transportation',
              'rating': 4.0,
              'address': 'Airport Rd, Dabolim, Goa 403801',
              'tags': ['airport', 'arrival', 'car rental'],
            },
            {
              'id': 'Artjuna-Cafe',
              'name': 'Artjuna Cafe',
              'description':
                  'A lush, bohemian oasis nestled in Assagao, offering a delectable vegetarian breakfast spread amidst tranquil gardens and a vibrant shop.',
              'latitude': 15.5898,
              'longitude': 73.7845,
              'imageUrl':
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Artjuna.jpg/1280px-Artjuna.jpg',
              'category': 'Cafe',
              'rating': 4.5,
              'address': '940, Market Rd, Monteiro Vaddo, Anjuna, Goa 403509',
              'tags': ['vegetarian', 'breakfast', 'bohemian', 'garden', 'cafe'],
            },
          ],
        },
      ],
    };
  }

  // Legacy method for backward compatibility
  Future<Itinerary> generateItineraryFromRequest(TripRequest request) async {
    final data = await getItinerary(request.toString());
    if (data.containsKey('itinerary')) {
      return Itinerary.fromJson(data);
    } else {
      return _getSampleItinerary(request.toString());
    }
  }

  // Fallback sample data when API is not available
  Itinerary _getSampleItinerary(String userInput) {
    // Generate sample response based on the request
    final sampleResponse = {
      "id": "sample_${DateTime.now().millisecondsSinceEpoch}",
      "title": "Goa Adventure Trip",
      "description": "A 5-day adventure exploring Goa's beaches, nightlife, and culture",
      "destination": "Goa",
      "start_date": "2024-12-01",
      "end_date": "2024-12-05",
      "travelers": 2,
      "itinerary": [
        {
          "day": 1,
          "morning":
              "Arrival at Goa Airport (GOI). Pick up a pre-booked self-drive car from a reputable service like Vailankanni Car Rentals or MyChoize (approx. ₹1500-2000/day for a compact car). Drive to North Goa and check into a hotel in Anjuna or Vagator (e.g., W Goa, The Park Calangute, or a well-rated boutique hotel matching the budget). Relax and freshen up. For breakfast, head to Artjuna Cafe in Assagao for a delicious vegetarian breakfast spread amidst a bohemian ambiance (estimated cost for breakfast: ₹800).",
          "afternoon":
              "Explore the vibrant Anjuna Flea Market (open on Wednesdays, if applicable for your December trip – confirm exact operating days closer to the date). Haggle for souvenirs, clothes, and handicrafts. Enjoy street food snacks like 'Ros Omelette' (vegetarian option available) from local stalls (estimated cost for market and snacks: ₹1500). Later, relax at Anjuna Beach, soaking in the sun and enjoying the lively atmosphere.",
          "evening":
              "Experience North Goa's famous nightlife. Start with dinner at Como Pizzeria for excellent vegetarian pizzas and Italian fare (estimated cost: ₹2000). Afterwards, head to Curlies Beach Shack or Shiva Valley (confirm current opening status closer to your travel date as some venues change) on Anjuna Beach for trance music and lively party vibes. Enjoy drinks and dance the night away (estimated cost for drinks and entry: ₹4000).",
          "estimated_cost": 10300,
        },
        {
          "day": 2,
          "morning":
              "Start the day with a visit to the Chapora Fort for panoramic views of Vagator Beach and the Morjim coastline – perfect for photos. Grab a quick vegetarian breakfast at a local cafe near Vagator (e.g., German Bakery, known for veg options; estimated cost: ₹600).",
          "afternoon":
              "Head to Mandrem Beach for a more relaxed vibe. Enjoy a leisurely vegetarian lunch at one of the peaceful beach shacks (estimated cost: ₹1500). Afterwards, consider a kayaking session (pre-book if possible, estimated cost: ₹1000 per person) or simply relax by the serene waters.",
          "evening":
              "Explore the sophisticated nightlife of North Goa. Enjoy a delectable vegetarian dinner at Olive Bar & Kitchen in Vagator, known for its Mediterranean cuisine and stunning sunset views (estimated cost: ₹3500). Later, head to Tito's Lane in Baga for a classic Goa clubbing experience. Options like Cafe Mambo or Club Titos offer mainstream music and a lively crowd (estimated cost for drinks and entry: ₹3000).",
          "estimated_cost": 9600,
        },
        {
          "day": 3,
          "morning":
              "Drive to Old Goa to immerse yourselves in its rich history and architecture. Visit the Basilica of Bom Jesus and Se Cathedral. Have a light vegetarian breakfast at a local eatery in Old Goa (estimated cost: ₹500).",
          "afternoon":
              "Continue exploring Old Goa, perhaps visiting the Church of St. Cajetan or the Museum of Christian Art. For lunch, try a local vegetarian thali at a simple yet authentic restaurant in the area (estimated cost: ₹1000). Afterwards, drive back towards the central part of Goa.",
          "evening":
              "Experience a different side of Goan entertainment with an evening at a casino. Head to Deltin Jaqk for a fun-filled night of gaming and entertainment (entry packages often include food and drinks; estimated cost: ₹3000 per person, so ₹6000 for a couple). Enjoy the buffet dinner and try your luck at the tables.",
          "estimated_cost": 7500,
        },
        {
          "day": 4,
          "morning":
              "Embark on a scenic drive to South Goa. Check into a hotel near Palolem or Agonda Beach (e.g., Agonda Serenity Resort or a similar beachfront property within budget). Enjoy a peaceful vegetarian breakfast at your hotel or a nearby cafe (estimated cost: ₹800).",
          "afternoon":
              "Spend the afternoon relaxing on the beautiful Palolem Beach. Enjoy swimming, sunbathing, or take a boat trip to Butterfly Beach (if available and weather permits; estimated cost: ₹1500 for the boat trip). For lunch, enjoy fresh vegetarian dishes at Cheeky Chilli in Palolem (estimated cost: ₹1500).",
          "evening":
              "Experience the laid-back yet vibrant nightlife of South Goa. Enjoy a romantic candle-lit vegetarian dinner right on Palolem Beach at one of the many shacks (inquire with your hotel or a specific shack a day in advance for arrangements; estimated cost: ₹3000). After dinner, enjoy live music or a fire show if available, savoring cocktails by the sea (estimated cost for drinks: ₹2000).",
          "estimated_cost": 8800,
        },
        {
          "day": 5,
          "morning":
              "Enjoy a final leisurely vegetarian breakfast in South Goa (estimated cost: ₹700). Depending on your flight schedule, you could visit another serene beach like Cola Beach (be mindful of the driving conditions, especially if it's off-road) or Majorda Beach for a final glimpse of Goa's natural beauty.",
          "afternoon":
              "Begin your journey back to Goa Airport. Stop for a quick vegetarian lunch at a well-rated restaurant en route, or pack some snacks (estimated cost: ₹1000). Return your rental car at the airport.",
          "evening":
              "Depart from Goa Airport (GOI) with wonderful memories of your food and nightlife adventure.",
          "estimated_cost": 1700,
        },
      ],
      "total_estimated_cost": 37900,
    };

    return Itinerary.fromJson(sampleResponse);
  }
}
