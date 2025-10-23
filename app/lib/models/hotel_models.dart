class HotelSearchRequest {
  final String location;
  final String checkInDate;
  final String checkOutDate;
  final int adults;
  final int? children;
  final int? rooms;
  final String? sortBy;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? amenities;

  HotelSearchRequest({
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    this.children,
    this.rooms,
    this.sortBy,
    this.minPrice,
    this.maxPrice,
    this.amenities,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'adults': adults,
      if (children != null) 'children': children,
      if (rooms != null) 'rooms': rooms,
      if (sortBy != null) 'sort_by': sortBy,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (amenities != null) 'amenities': amenities,
    };
  }

  String toQueryString() {
    final params = <String, String>{
      'location': location,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'adults': adults.toString(),
    };
    
    if (children != null) {
      params['children'] = children.toString();
    }
    if (rooms != null) {
      params['rooms'] = rooms.toString();
    }
    if (sortBy != null) {
      params['sort_by'] = sortBy!;
    }
    if (minPrice != null) {
      params['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      params['max_price'] = maxPrice.toString();
    }
    if (amenities != null) {
      params['amenities'] = amenities!.join(',');
    }
    
    return params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }
}

class Hotel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final String imageUrl;
  final List<String> images;
  final List<String> amenities;
  final String hotelType;
  final int stars;
  final bool isAvailable;
  final bool isRefundable;
  final bool isFreeCancellation;
  final String cancellationPolicy;
  final String checkInTime;
  final String checkOutTime;
  final int totalRooms;
  final int availableRooms;
  final String contactNumber;
  final String email;
  final String website;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.currency,
    required this.imageUrl,
    required this.images,
    required this.amenities,
    required this.hotelType,
    required this.stars,
    required this.isAvailable,
    required this.isRefundable,
    required this.isFreeCancellation,
    required this.cancellationPolicy,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalRooms,
    required this.availableRooms,
    required this.contactNumber,
    required this.email,
    required this.website,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      pricePerNight: (json['price_per_night'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      imageUrl: json['image_url'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      hotelType: json['hotel_type'] ?? 'Hotel',
      stars: json['stars'] ?? 3,
      isAvailable: json['is_available'] ?? true,
      isRefundable: json['is_refundable'] ?? false,
      isFreeCancellation: json['is_free_cancellation'] ?? false,
      cancellationPolicy: json['cancellation_policy'] ?? '',
      checkInTime: json['check_in_time'] ?? '14:00',
      checkOutTime: json['check_out_time'] ?? '11:00',
      totalRooms: json['total_rooms'] ?? 0,
      availableRooms: json['available_rooms'] ?? 0,
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'review_count': reviewCount,
      'price_per_night': pricePerNight,
      'currency': currency,
      'image_url': imageUrl,
      'images': images,
      'amenities': amenities,
      'hotel_type': hotelType,
      'stars': stars,
      'is_available': isAvailable,
      'is_refundable': isRefundable,
      'is_free_cancellation': isFreeCancellation,
      'cancellation_policy': cancellationPolicy,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'contact_number': contactNumber,
      'email': email,
      'website': website,
    };
  }

  String get formattedPrice {
    return '$currency ${pricePerNight.toStringAsFixed(0)}';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get starsDisplay {
    return '★' * stars;
  }

  String get reviewText {
    if (reviewCount == 0) return 'No reviews';
    if (reviewCount == 1) return '1 review';
    return '$reviewCount reviews';
  }

  String get availabilityText {
    if (availableRooms == 0) return 'Sold out';
    if (availableRooms <= 3) return 'Only $availableRooms left';
    return 'Available';
  }
}

class HotelSearchResponse {
  final List<Hotel> hotels;
  final String searchId;
  final DateTime searchTime;
  final String location;
  final int totalResults;
  final Map<String, dynamic> filters;

  HotelSearchResponse({
    required this.hotels,
    required this.searchId,
    required this.searchTime,
    required this.location,
    required this.totalResults,
    required this.filters,
  });

  factory HotelSearchResponse.fromJson(Map<String, dynamic> json) {
    return HotelSearchResponse(
      hotels: (json['hotels'] as List<dynamic>?)
          ?.map((hotel) => Hotel.fromJson(hotel))
          .toList() ?? [],
      searchId: json['search_id'] ?? '',
      searchTime: DateTime.parse(json['search_time']),
      location: json['location'] ?? '',
      totalResults: json['total_results'] ?? 0,
      filters: json['filters'] ?? {},
    );
  }
}

class HotelLocation {
  final String city;
  final String state;
  final String country;
  final String code;
  final double latitude;
  final double longitude;

  HotelLocation({
    required this.city,
    required this.state,
    required this.country,
    required this.code,
    required this.latitude,
    required this.longitude,
  });

  factory HotelLocation.fromJson(Map<String, dynamic> json) {
    return HotelLocation(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      code: json['code'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get displayName => '$city, $state';
  String get fullName => '$city, $state, $country';
}
