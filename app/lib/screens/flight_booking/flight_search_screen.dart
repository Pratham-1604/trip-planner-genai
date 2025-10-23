import 'package:flutter/material.dart';
import '../../models/itinerary.dart';
import '../../models/flight_models.dart';
import '../../services/flight_service.dart';
import '../../widgets/elegant_theme.dart';
import 'round_trip_highlights_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  final Itinerary itinerary;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adults;
  final int children;
  final int infants;
  final Airport? originAirport;
  final Airport? destinationAirport;

  const FlightSearchScreen({
    super.key,
    required this.itinerary,
    required this.departureDate,
    this.returnDate,
    required this.adults,
    required this.children,
    required this.infants,
    this.originAirport,
    this.destinationAirport,
  });

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen>
    with SingleTickerProviderStateMixin {
  final FlightService _flightService = FlightService();
  FlightSearchResponse? _searchResponse;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.returnDate != null ? 2 : 1,
      vsync: this,
    );
    _searchFlights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = FlightSearchRequest(
        origin: widget.originAirport?.code ?? 'DEL', // Use provided airport or default to Delhi
        destination: widget.destinationAirport?.code ?? widget.itinerary.destination.toUpperCase(),
        departureDate: widget.departureDate.toIso8601String().split('T')[0],
        returnDate: widget.returnDate?.toIso8601String().split('T')[0],
        adults: widget.adults,
        children: widget.children,
        infants: widget.infants,
      );

      final response = await _flightService.searchFlights(request);
      
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
          'Flight Search Results',
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
            onPressed: _searchFlights,
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

    if (_searchResponse == null || _searchResponse!.outboundFlights.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Search summary
        _buildSearchSummary(),
        
        // Tab bar for round trip
        if (widget.returnDate != null)
          Container(
            color: ElegantTheme.white,
            child: TabBar(
              controller: _tabController,
              labelColor: ElegantTheme.primaryBlue,
              unselectedLabelColor: ElegantTheme.textSecondary,
              indicatorColor: ElegantTheme.primaryBlue,
              tabs: const [
                Tab(text: 'Outbound Flights'),
                Tab(text: 'Return Flights'),
              ],
            ),
          ),

        // Flight results
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFlightList(_searchResponse!.outboundFlights, false),
              if (widget.returnDate != null)
                _buildFlightList(_searchResponse!.returnFlights ?? [], true),
            ],
          ),
        ),

        // Round trip highlights button
        if (widget.returnDate != null && _searchResponse!.returnFlights != null)
          _buildRoundTripHighlightsButton(),
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
            'Searching for flights...',
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
              onPressed: _searchFlights,
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
              Icons.flight_land,
              size: 64,
              color: ElegantTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Flights Found',
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
            Icons.flight_takeoff,
            color: ElegantTheme.lightBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'DEL → MUM',
            style: ElegantTheme.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(width: 16),
          Text(
            _formatDate(widget.departureDate),
            style: ElegantTheme.captionText,
          ),
          if (widget.returnDate != null) ...[
            const SizedBox(width: 16),
            Icon(
              Icons.flight_land,
              color: ElegantTheme.lightBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'MUM → DEL',
              style: ElegantTheme.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 16),
            Text(
              _formatDate(widget.returnDate!),
              style: ElegantTheme.captionText,
            ),
          ],
          const Spacer(),
          Text(
            '${widget.adults + widget.children + widget.infants} passengers',
            style: ElegantTheme.captionText,
          ),
        ],
      ),
    );
  }

  Widget _buildFlightList(List<Flight> flights, bool isReturn) {
    if (flights.isEmpty) {
      return Center(
        child: Text(
          'No ${isReturn ? 'return' : 'outbound'} flights found',
          style: ElegantTheme.bodyText,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return _buildFlightCard(flight, isReturn);
      },
    );
  }

  Widget _buildFlightCard(Flight flight, bool isReturn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ElegantTheme.cardDecoration,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to flight details or booking
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected ${flight.airline} ${flight.flightNumber}'),
              backgroundColor: ElegantTheme.lightBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Flight header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ElegantTheme.lightAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.flight,
                      color: ElegantTheme.lightBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${flight.airline} ${flight.flightNumber}',
                          style: ElegantTheme.cardTitle,
                        ),
                        Text(
                          flight.aircraft,
                          style: ElegantTheme.captionText,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    flight.formattedPrice,
                    style: ElegantTheme.cardTitle.copyWith(
                      color: ElegantTheme.accentGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Flight details
              Row(
                children: [
                  // Departure
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(flight.departureTime),
                          style: ElegantTheme.cardTitle.copyWith(fontSize: 18),
                        ),
                        Text(
                          flight.origin,
                          style: ElegantTheme.captionText,
                        ),
                        Text(
                          'Terminal ${flight.terminal}',
                          style: ElegantTheme.captionText.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  // Duration and stops
                  Column(
                    children: [
                      Text(
                        flight.formattedDuration,
                        style: ElegantTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 1,
                        width: 60,
                        color: ElegantTheme.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.stopsText,
                        style: ElegantTheme.captionText,
                      ),
                    ],
                  ),

                  // Arrival
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(flight.arrivalTime),
                          style: ElegantTheme.cardTitle.copyWith(fontSize: 18),
                        ),
                        Text(
                          flight.destination,
                          style: ElegantTheme.captionText,
                        ),
                        Text(
                          'Gate ${flight.gate}',
                          style: ElegantTheme.captionText.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Flight features
              Row(
                children: [
                  if (flight.isRefundable)
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
                  if (flight.isChangeable) ...[
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
                        'Changeable',
                        style: ElegantTheme.captionText.copyWith(
                          color: ElegantTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${flight.availableSeats} seats left',
                    style: ElegantTheme.captionText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundTripHighlightsButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ElegantTheme.white,
        border: Border(
          top: BorderSide(color: ElegantTheme.subtleBorder, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElegantTheme.createElegantButton(
          text: 'View Round Trip Highlights',
          onPressed: () {
            if (_searchResponse?.outboundFlights != null && 
                _searchResponse?.returnFlights != null) {
              final highlights = _flightService.generateRoundTripHighlights(
                _searchResponse!.outboundFlights,
                _searchResponse!.returnFlights!,
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoundTripHighlightsScreen(
                    highlights: highlights,
                  ),
                ),
              );
            }
          },
          backgroundColor: ElegantTheme.accentGold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

