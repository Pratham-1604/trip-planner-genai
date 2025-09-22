import 'package:flutter/material.dart';
import '../widgets/elegant_theme.dart';
import '../models/hotel_models.dart';
import '../services/hotel_service.dart';

class HotelSearchScreen extends StatefulWidget {
  final HotelSearchRequest searchRequest;

  const HotelSearchScreen({
    super.key,
    required this.searchRequest,
  });

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final HotelService _hotelService = HotelService();
  HotelSearchResponse? _searchResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchHotels();
  }

  Future<void> _searchHotels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _hotelService.searchHotels(widget.searchRequest);
      
      setState(() {
        _searchResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Hotel Search Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ElegantTheme.white,
          ),
        ),
        backgroundColor: ElegantTheme.primaryBlue,
        foregroundColor: ElegantTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _searchHotels,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_searchResponse == null || _searchResponse!.hotels.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Search summary
        _buildSearchSummary(),
        
        // Hotel results
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResponse!.hotels.length,
            itemBuilder: (context, index) {
              final hotel = _searchResponse!.hotels[index];
              return _buildHotelCard(hotel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ElegantTheme.lightBlue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Searching for hotels...',
            style: ElegantTheme.bodyText,
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few moments',
            style: ElegantTheme.captionText,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: ElegantTheme.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ElegantTheme.accentOrange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Search Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unknown error occurred',
              style: ElegantTheme.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElegantTheme.createElegantButton(
              text: 'Try Again',
              onPressed: _searchHotels,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: ElegantTheme.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hotel,
              size: 64,
              color: ElegantTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Hotels Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search criteria',
              style: ElegantTheme.bodyText,
            ),
            const SizedBox(height: 24),
            ElegantTheme.createElegantButton(
              text: 'Modify Search',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSummary() {
    final nights = _calculateNights();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ElegantTheme.white,
        border: Border(
          bottom: BorderSide(color: ElegantTheme.subtleBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hotel,
            color: ElegantTheme.lightBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.searchRequest.location,
            style: ElegantTheme.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(width: 16),
          Text(
            _formatDate(DateTime.parse(widget.searchRequest.checkInDate)),
            style: ElegantTheme.captionText,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: ElegantTheme.mediumGray,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(DateTime.parse(widget.searchRequest.checkOutDate)),
            style: ElegantTheme.captionText,
          ),
          const Spacer(),
          Text(
            '${widget.searchRequest.adults + (widget.searchRequest.children ?? 0)} guests • $nights nights',
            style: ElegantTheme.captionText,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ElegantTheme.cardDecoration,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to hotel details or booking
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected ${hotel.name}'),
              backgroundColor: ElegantTheme.lightBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel image
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ElegantTheme.softGray,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        hotel.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ElegantTheme.softGray,
                            child: Icon(
                              Icons.hotel,
                              color: ElegantTheme.mediumGray,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Hotel details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: ElegantTheme.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel.location,
                          style: ElegantTheme.captionText,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              hotel.starsDisplay,
                              style: TextStyle(
                                color: ElegantTheme.accentGold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hotel.formattedRating,
                              style: ElegantTheme.captionText.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${hotel.reviewText})',
                              style: ElegantTheme.captionText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        hotel.formattedPrice,
                        style: ElegantTheme.cardTitle.copyWith(
                          color: ElegantTheme.accentGreen,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'per night',
                        style: ElegantTheme.captionText,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Hotel amenities
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: hotel.amenities.take(4).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ElegantTheme.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ElegantTheme.lightBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      amenity,
                      style: ElegantTheme.captionText.copyWith(
                        color: ElegantTheme.primaryBlue,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Hotel features and availability
              Row(
                children: [
                  if (hotel.isRefundable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ElegantTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ElegantTheme.accentGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Refundable',
                        style: ElegantTheme.captionText.copyWith(
                          color: ElegantTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (hotel.isFreeCancellation) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ElegantTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ElegantTheme.accentOrange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Free Cancellation',
                        style: ElegantTheme.captionText.copyWith(
                          color: ElegantTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    hotel.availabilityText,
                    style: ElegantTheme.captionText.copyWith(
                      color: hotel.availableRooms == 0 
                          ? ElegantTheme.accentOrange 
                          : ElegantTheme.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateNights() {
    final checkIn = DateTime.parse(widget.searchRequest.checkInDate);
    final checkOut = DateTime.parse(widget.searchRequest.checkOutDate);
    return checkOut.difference(checkIn).inDays;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
