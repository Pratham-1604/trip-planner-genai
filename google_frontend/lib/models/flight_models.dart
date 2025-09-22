class FlightSearchRequest {
  final String origin;
  final String destination;
  final String departureDate;
  final String? returnDate;
  final int adults;
  final int? children;
  final int? infants;

  FlightSearchRequest({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.adults,
    this.children,
    this.infants,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'departure_date': departureDate,
      if (returnDate != null) 'return_date': returnDate,
      'adults': adults,
      if (children != null) 'children': children,
      if (infants != null) 'infants': infants,
    };
  }

  String toQueryString() {
    final params = <String, String>{
      'origin': origin,
      'destination': destination,
      'departure_date': departureDate,
      'adults': adults.toString(),
    };
    
    if (returnDate != null) {
      params['return_date'] = returnDate!;
    }
    if (children != null) {
      params['children'] = children.toString();
    }
    if (infants != null) {
      params['infants'] = infants.toString();
    }
    
    return params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }
}

class Flight {
  final String id;
  final String airline;
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int duration; // in minutes
  final double price;
  final String currency;
  final String cabinClass;
  final int stops;
  final List<String> stopoverCities;
  final String aircraft;
  final String terminal;
  final String gate;
  final bool isRefundable;
  final bool isChangeable;
  final String bookingClass;
  final int availableSeats;

  Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.cabinClass,
    required this.stops,
    required this.stopoverCities,
    required this.aircraft,
    required this.terminal,
    required this.gate,
    required this.isRefundable,
    required this.isChangeable,
    required this.bookingClass,
    required this.availableSeats,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? '',
      airline: json['airline'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      cabinClass: json['cabin_class'] ?? 'Economy',
      stops: json['stops'] ?? 0,
      stopoverCities: List<String>.from(json['stopover_cities'] ?? []),
      aircraft: json['aircraft'] ?? '',
      terminal: json['terminal'] ?? '',
      gate: json['gate'] ?? '',
      isRefundable: json['is_refundable'] ?? false,
      isChangeable: json['is_changeable'] ?? false,
      bookingClass: json['booking_class'] ?? '',
      availableSeats: json['available_seats'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flight_number': flightNumber,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'currency': currency,
      'cabin_class': cabinClass,
      'stops': stops,
      'stopover_cities': stopoverCities,
      'aircraft': aircraft,
      'terminal': terminal,
      'gate': gate,
      'is_refundable': isRefundable,
      'is_changeable': isChangeable,
      'booking_class': bookingClass,
      'available_seats': availableSeats,
    };
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  String get formattedPrice {
    return '$currency ${price.toStringAsFixed(0)}';
  }

  String get stopsText {
    if (stops == 0) return 'Direct';
    if (stops == 1) return '1 stop';
    return '$stops stops';
  }
}

class FlightSearchResponse {
  final List<Flight> outboundFlights;
  final List<Flight>? returnFlights;
  final String searchId;
  final DateTime searchTime;
  final bool isRoundTrip;

  FlightSearchResponse({
    required this.outboundFlights,
    this.returnFlights,
    required this.searchId,
    required this.searchTime,
    required this.isRoundTrip,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      outboundFlights: (json['outbound_flights'] as List<dynamic>?)
          ?.map((flight) => Flight.fromJson(flight))
          .toList() ?? [],
      returnFlights: json['return_flights'] != null
          ? (json['return_flights'] as List<dynamic>)
              .map((flight) => Flight.fromJson(flight))
              .toList()
          : null,
      searchId: json['search_id'] ?? '',
      searchTime: DateTime.parse(json['search_time']),
      isRoundTrip: json['is_round_trip'] ?? false,
    );
  }
}

class RoundTripHighlight {
  final Flight outboundFlight;
  final Flight returnFlight;
  final double totalPrice;
  final String currency;
  final int totalDuration;
  final double savings;

  RoundTripHighlight({
    required this.outboundFlight,
    required this.returnFlight,
    required this.totalPrice,
    required this.currency,
    required this.totalDuration,
    required this.savings,
  });

  String get formattedTotalPrice {
    return '$currency ${totalPrice.toStringAsFixed(0)}';
  }

  String get formattedTotalDuration {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  String get formattedSavings {
    return '$currency ${savings.toStringAsFixed(0)}';
  }
}

class Airport {
  final String code;
  final String name;
  final String city;
  final String country;
  final String timezone;

  Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.country,
    required this.timezone,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'city': city,
      'country': country,
      'timezone': timezone,
    };
  }

  String get displayName => '$name ($code)';
  String get location => '$city, $country';
}

