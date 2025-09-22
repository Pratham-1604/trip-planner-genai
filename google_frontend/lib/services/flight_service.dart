import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_models.dart';

class FlightService {
  static const String baseUrl = 'https://your-api-server.com'; // Replace with your actual API URL
  
  // Search for flights
  Future<FlightSearchResponse> searchFlights(FlightSearchRequest request) async {
    try {
      final queryString = request.toQueryString();
      final url = Uri.parse('$baseUrl/search-flights?$queryString');
      
      print('Searching flights: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FlightSearchResponse.fromJson(data);
      } else {
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching flights: $e');
      // Return mock data for development
      return _getMockFlightSearchResponse(request);
    }
  }

  // Get airport information
  Future<List<Airport>> getAirports() async {
    try {
      final url = Uri.parse('$baseUrl/airports');
      
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
            .map((airport) => Airport.fromJson(airport))
            .toList();
      } else {
        throw Exception('Failed to get airports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting airports: $e');
      // Return mock data for development
      return _getMockAirports();
    }
  }

  // Generate round trip highlights
  List<RoundTripHighlight> generateRoundTripHighlights(
    List<Flight> outboundFlights,
    List<Flight> returnFlights,
  ) {
    List<RoundTripHighlight> highlights = [];
    
    for (final outbound in outboundFlights) {
      for (final returnFlight in returnFlights) {
        final totalPrice = outbound.price + returnFlight.price;
        final totalDuration = outbound.duration + returnFlight.duration;
        
        // Calculate savings (mock calculation - 5% discount for round trip)
        final savings = totalPrice * 0.05;
        
        highlights.add(RoundTripHighlight(
          outboundFlight: outbound,
          returnFlight: returnFlight,
          totalPrice: totalPrice,
          currency: outbound.currency,
          totalDuration: totalDuration,
          savings: savings,
        ));
      }
    }
    
    // Sort by price and return top 10
    highlights.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    return highlights.take(10).toList();
  }

  // Mock data for development
  FlightSearchResponse _getMockFlightSearchResponse(FlightSearchRequest request) {
    final now = DateTime.now();
    final departureDate = DateTime.parse(request.departureDate);
    
    return FlightSearchResponse(
      outboundFlights: _generateMockFlights(
        request.origin,
        request.destination,
        departureDate,
        isReturn: false,
      ),
      returnFlights: request.returnDate != null
          ? _generateMockFlights(
              request.destination,
              request.origin,
              DateTime.parse(request.returnDate!),
              isReturn: true,
            )
          : null,
      searchId: 'mock_${now.millisecondsSinceEpoch}',
      searchTime: now,
      isRoundTrip: request.returnDate != null,
    );
  }

  List<Flight> _generateMockFlights(
    String origin,
    String destination,
    DateTime date,
    {required bool isReturn}
  ) {
    final flights = <Flight>[];
    final airlines = ['Air India', 'IndiGo', 'SpiceJet', 'Vistara', 'GoAir'];
    final aircraft = ['Boeing 737', 'Airbus A320', 'Boeing 777', 'Airbus A321'];
    
    for (int i = 0; i < 5; i++) {
      final departureHour = 6 + (i * 3);
      final departureTime = DateTime(
        date.year,
        date.month,
        date.day,
        departureHour,
        (i * 15) % 60,
      );
      
      final duration = 120 + (i * 30); // 2-4 hours
      final arrivalTime = departureTime.add(Duration(minutes: duration));
      
      flights.add(Flight(
        id: 'flight_${origin}_${destination}_${i}',
        airline: airlines[i % airlines.length],
        flightNumber: '${airlines[i % airlines.length].substring(0, 2).toUpperCase()}${100 + i}',
        origin: origin,
        destination: destination,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        duration: duration,
        price: _calculateFlightPrice(origin, destination, departureTime, i),
        currency: 'INR',
        cabinClass: 'Economy',
        stops: i % 3 == 0 ? 0 : 1,
        stopoverCities: i % 3 == 0 ? [] : ['BLR'],
        aircraft: aircraft[i % aircraft.length],
        terminal: 'T${(i % 3) + 1}',
        gate: '${String.fromCharCode(65 + (i % 26))}${10 + i}',
        isRefundable: i % 2 == 0,
        isChangeable: true,
        bookingClass: 'Y',
        availableSeats: 10 - i,
      ));
    }
    
    return flights;
  }

  double _calculateFlightPrice(String origin, String destination, DateTime departureTime, int index) {
    // Base price by route distance (simplified)
    final routePrices = {
      'DEL-BOM': 8000, 'BOM-DEL': 8000,
      'DEL-BLR': 6000, 'BLR-DEL': 6000,
      'DEL-MAA': 7000, 'MAA-DEL': 7000,
      'DEL-HYD': 5500, 'HYD-DEL': 5500,
      'DEL-CCU': 5000, 'CCU-DEL': 5000,
      'DEL-AMD': 4000, 'AMD-DEL': 4000,
      'DEL-GOI': 4500, 'GOI-DEL': 4500,
      'BOM-BLR': 3000, 'BLR-BOM': 3000,
      'BOM-MAA': 2500, 'MAA-BOM': 2500,
      'BOM-HYD': 2000, 'HYD-BOM': 2000,
      'BOM-CCU': 4000, 'CCU-BOM': 4000,
      'BOM-GOI': 1500, 'GOI-BOM': 1500,
    };
    
    final routeKey = '$origin-$destination';
    final basePrice = routePrices[routeKey] ?? 5000; // Default price
    
    // Time-based pricing (morning/evening flights are more expensive)
    double timeMultiplier = 1.0;
    final hour = departureTime.hour;
    if (hour >= 6 && hour <= 9) {
      timeMultiplier = 1.3; // Morning peak
    } else if (hour >= 18 && hour <= 21) {
      timeMultiplier = 1.2; // Evening peak
    } else if (hour >= 22 || hour <= 5) {
      timeMultiplier = 0.8; // Night discount
    }
    
    // Airline pricing variation
    final airlineMultiplier = 0.8 + (index * 0.1); // 0.8 to 1.2
    
    // Weekend pricing
    final isWeekend = departureTime.weekday >= 6;
    final weekendMultiplier = isWeekend ? 1.2 : 1.0;
    
    // Advance booking discount (simplified)
    final daysUntilFlight = departureTime.difference(DateTime.now()).inDays;
    final advanceBookingMultiplier = daysUntilFlight > 30 ? 0.9 : 1.0;
    
    final finalPrice = basePrice * timeMultiplier * airlineMultiplier * weekendMultiplier * advanceBookingMultiplier;
    
    return finalPrice.roundToDouble();
  }

  List<Airport> _getMockAirports() {
    return [
      Airport(
        code: 'DEL',
        name: 'Indira Gandhi International Airport',
        city: 'New Delhi',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
      Airport(
        code: 'MUM',
        name: 'Chhatrapati Shivaji Maharaj International Airport',
        city: 'Mumbai',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
      Airport(
        code: 'BLR',
        name: 'Kempegowda International Airport',
        city: 'Bangalore',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
      Airport(
        code: 'CCU',
        name: 'Netaji Subhash Chandra Bose International Airport',
        city: 'Kolkata',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
      Airport(
        code: 'HYD',
        name: 'Rajiv Gandhi International Airport',
        city: 'Hyderabad',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
      Airport(
        code: 'AMD',
        name: 'Sardar Vallabhbhai Patel International Airport',
        city: 'Ahmedabad',
        country: 'India',
        timezone: 'Asia/Kolkata',
      ),
    ];
  }
}

