import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_models.dart';

class HotelService {
  static const String baseUrl = 'https://your-api-server.com'; // Replace with your actual API URL
  
  // Search for hotels
  Future<HotelSearchResponse> searchHotels(HotelSearchRequest request) async {
    try {
      final queryString = request.toQueryString();
      final url = Uri.parse('$baseUrl/search-hotels?$queryString');
      
      print('Searching hotels: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HotelSearchResponse.fromJson(data);
      } else {
        throw Exception('Failed to search hotels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching hotels: $e');
      // Return mock data for development
      return _getMockHotelSearchResponse(request);
    }
  }

  // Get hotel locations
  Future<List<HotelLocation>> getHotelLocations() async {
    try {
      final url = Uri.parse('$baseUrl/hotel-locations');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List<dynamic>)
            .map((location) => HotelLocation.fromJson(location))
            .toList();
      } else {
        throw Exception('Failed to get hotel locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting hotel locations: $e');
      // Return mock data for development
      return _getMockHotelLocations();
    }
  }

  // Get hotel details
  Future<Hotel> getHotelDetails(String hotelId) async {
    try {
      final url = Uri.parse('$baseUrl/hotels/$hotelId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Hotel.fromJson(data);
      } else {
        throw Exception('Failed to get hotel details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting hotel details: $e');
      // Return mock data for development
      return _getMockHotelDetails(hotelId);
    }
  }

  // Mock data for development
  HotelSearchResponse _getMockHotelSearchResponse(HotelSearchRequest request) {
    final now = DateTime.now();
    final checkInDate = DateTime.parse(request.checkInDate);
    final checkOutDate = DateTime.parse(request.checkOutDate);
    final nights = checkOutDate.difference(checkInDate).inDays;
    
    return HotelSearchResponse(
      hotels: _generateMockHotels(request.location, nights),
      searchId: 'mock_${now.millisecondsSinceEpoch}',
      searchTime: now,
      location: request.location,
      totalResults: 15,
      filters: {
        'price_range': {'min': 1000, 'max': 15000},
        'star_rating': [3, 4, 5],
        'amenities': ['WiFi', 'Pool', 'Gym', 'Spa', 'Restaurant'],
      },
    );
  }

  List<Hotel> _generateMockHotels(String location, int nights) {
    final hotels = <Hotel>[];
    final hotelNames = [
      'Grand Palace Hotel',
      'Royal Heritage Resort',
      'Luxury Suites',
      'Business Hotel Central',
      'Garden View Inn',
      'Seaside Resort',
      'Mountain Lodge',
      'City Center Hotel',
      'Boutique Hotel',
      'Family Resort',
      'Executive Suites',
      'Heritage Palace',
      'Modern Plaza',
      'Cozy Corner Inn',
      'Premium Resort',
    ];

    final amenities = [
      'Free WiFi',
      'Swimming Pool',
      'Fitness Center',
      'Restaurant',
      'Spa',
      'Room Service',
      'Airport Shuttle',
      'Parking',
      'Business Center',
      'Concierge',
    ];

    final hotelTypes = ['Hotel', 'Resort', 'Boutique Hotel', 'Business Hotel', 'Luxury Hotel'];

    for (int i = 0; i < 15; i++) {
      final basePrice = _calculateBasePrice(location, i);
      final pricePerNight = basePrice + (i * 500);
      
      hotels.add(Hotel(
        id: 'hotel_${location.toLowerCase()}_$i',
        name: hotelNames[i % hotelNames.length],
        description: 'A beautiful hotel in the heart of $location with modern amenities and excellent service.',
        location: location,
        address: '${i + 1} Main Street, $location',
        latitude: 19.0760 + (i * 0.01),
        longitude: 72.8777 + (i * 0.01),
        rating: 3.5 + (i * 0.2),
        reviewCount: 50 + (i * 25),
        pricePerNight: pricePerNight,
        currency: 'INR',
        imageUrl: 'https://images.unsplash.com/photo-${1564501049 + i}?w=400',
        images: [
          'https://images.unsplash.com/photo-${1564501049 + i}?w=400',
          'https://images.unsplash.com/photo-${1564501050 + i}?w=400',
          'https://images.unsplash.com/photo-${1564501051 + i}?w=400',
        ],
        amenities: amenities.take(5 + (i % 6)).toList(),
        hotelType: hotelTypes[i % hotelTypes.length],
        stars: 3 + (i % 3),
        isAvailable: i % 10 != 0, // 90% availability
        isRefundable: i % 2 == 0,
        isFreeCancellation: i % 3 == 0,
        cancellationPolicy: i % 2 == 0 ? 'Free cancellation until 24 hours before check-in' : 'Non-refundable',
        checkInTime: '14:00',
        checkOutTime: '11:00',
        totalRooms: 50 + (i * 10),
        availableRooms: 10 + (i * 2),
        contactNumber: '+91-${9000000000 + i}',
        email: 'info@${hotelNames[i % hotelNames.length].toLowerCase().replaceAll(' ', '')}.com',
        website: 'https://${hotelNames[i % hotelNames.length].toLowerCase().replaceAll(' ', '')}.com',
      ));
    }
    
    return hotels;
  }

  double _calculateBasePrice(String location, int index) {
    final locationPrices = {
      'Mumbai': 8000.0,
      'Delhi': 6000.0,
      'Bangalore': 5000.0,
      'Chennai': 4500.0,
      'Hyderabad': 4000.0,
      'Kolkata': 3500.0,
      'Pune': 3000.0,
      'Goa': 2500.0,
      'Jaipur': 2000.0,
      'Kochi': 1800.0,
    };
    
    return locationPrices[location] ?? 3000.0;
  }

  List<HotelLocation> _getMockHotelLocations() {
    return [
      HotelLocation(
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        code: 'BOM',
        latitude: 19.0760,
        longitude: 72.8777,
      ),
      HotelLocation(
        city: 'Delhi',
        state: 'Delhi',
        country: 'India',
        code: 'DEL',
        latitude: 28.7041,
        longitude: 77.1025,
      ),
      HotelLocation(
        city: 'Bangalore',
        state: 'Karnataka',
        country: 'India',
        code: 'BLR',
        latitude: 12.9716,
        longitude: 77.5946,
      ),
      HotelLocation(
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        code: 'MAA',
        latitude: 13.0827,
        longitude: 80.2707,
      ),
      HotelLocation(
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        code: 'HYD',
        latitude: 17.3850,
        longitude: 78.4867,
      ),
      HotelLocation(
        city: 'Kolkata',
        state: 'West Bengal',
        country: 'India',
        code: 'CCU',
        latitude: 22.5726,
        longitude: 88.3639,
      ),
      HotelLocation(
        city: 'Pune',
        state: 'Maharashtra',
        country: 'India',
        code: 'PNQ',
        latitude: 18.5204,
        longitude: 73.8567,
      ),
      HotelLocation(
        city: 'Goa',
        state: 'Goa',
        country: 'India',
        code: 'GOI',
        latitude: 15.2993,
        longitude: 74.1240,
      ),
      HotelLocation(
        city: 'Jaipur',
        state: 'Rajasthan',
        country: 'India',
        code: 'JAI',
        latitude: 26.9124,
        longitude: 75.7873,
      ),
      HotelLocation(
        city: 'Kochi',
        state: 'Kerala',
        country: 'India',
        code: 'COK',
        latitude: 9.9312,
        longitude: 76.2673,
      ),
    ];
  }

  Hotel _getMockHotelDetails(String hotelId) {
    return Hotel(
      id: hotelId,
      name: 'Grand Palace Hotel',
      description: 'A luxurious hotel in the heart of the city with world-class amenities and exceptional service.',
      location: 'Mumbai',
      address: '123 Main Street, Mumbai, Maharashtra',
      latitude: 19.0760,
      longitude: 72.8777,
      rating: 4.5,
      reviewCount: 250,
      pricePerNight: 8000,
      currency: 'INR',
      imageUrl: 'https://images.unsplash.com/photo-1564501049-5c6b6c8b8b8b?w=400',
      images: [
        'https://images.unsplash.com/photo-1564501049-5c6b6c8b8b8b?w=400',
        'https://images.unsplash.com/photo-1564501050-5c6b6c8b8b8b?w=400',
        'https://images.unsplash.com/photo-1564501051-5c6b6c8b8b8b?w=400',
      ],
      amenities: ['Free WiFi', 'Swimming Pool', 'Fitness Center', 'Restaurant', 'Spa'],
      hotelType: 'Luxury Hotel',
      stars: 5,
      isAvailable: true,
      isRefundable: true,
      isFreeCancellation: true,
      cancellationPolicy: 'Free cancellation until 24 hours before check-in',
      checkInTime: '14:00',
      checkOutTime: '11:00',
      totalRooms: 100,
      availableRooms: 25,
      contactNumber: '+91-9000000000',
      email: 'info@grandpalace.com',
      website: 'https://grandpalace.com',
    );
  }
}
