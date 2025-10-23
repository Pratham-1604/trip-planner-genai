import 'package:flutter/material.dart';
import '../../models/itinerary.dart';
import '../../models/flight_models.dart';
import '../../widgets/elegant_theme.dart';
import 'flight_search_screen.dart';

class DateSelectionScreen extends StatefulWidget {
  final Itinerary itinerary;
  final Airport? originAirport;
  final Airport? destinationAirport;

  const DateSelectionScreen({
    super.key,
    required this.itinerary,
    this.originAirport,
    this.destinationAirport,
  });

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = true;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  @override
  void initState() {
    super.initState();
    // Set default dates based on itinerary if available
    if (widget.itinerary.startDate.isNotEmpty) {
      try {
        _departureDate = DateTime.parse(widget.itinerary.startDate);
      } catch (e) {
        print('Error parsing start date: $e');
        _departureDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      _departureDate = DateTime.now().add(const Duration(days: 1));
    }
    
    if (widget.itinerary.endDate.isNotEmpty) {
      try {
        _returnDate = DateTime.parse(widget.itinerary.endDate);
      } catch (e) {
        print('Error parsing end date: $e');
        _returnDate = DateTime.now().add(const Duration(days: 8));
      }
    } else {
      _returnDate = DateTime.now().add(const Duration(days: 8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Select Travel Dates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ElegantTheme.white,
          ),
        ),
        backgroundColor: ElegantTheme.primaryBlue,
        foregroundColor: ElegantTheme.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.travel_explore,
                        color: ElegantTheme.lightBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.itinerary.title,
                          style: ElegantTheme.sectionTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.itinerary.destination} • ${widget.itinerary.days.length} days',
                    style: ElegantTheme.bodyText.copyWith(
                      color: ElegantTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trip type selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Type',
                    style: ElegantTheme.sectionTitle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTripTypeOption(
                          title: 'Round Trip',
                          subtitle: 'Return to origin',
                          icon: Icons.flight_land,
                          isSelected: _isRoundTrip,
                          onTap: () => setState(() => _isRoundTrip = true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTripTypeOption(
                          title: 'One Way',
                          subtitle: 'No return flight',
                          icon: Icons.flight_takeoff,
                          isSelected: !_isRoundTrip,
                          onTap: () => setState(() => _isRoundTrip = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Dates',
                    style: ElegantTheme.sectionTitle,
                  ),
                  const SizedBox(height: 20),
                  
                  // Departure date
                  _buildDateSelector(
                    title: 'Departure Date',
                    subtitle: 'When do you want to leave?',
                    date: _departureDate,
                    onTap: () => _selectDate(context, true),
                    icon: Icons.flight_takeoff,
                  ),
                  
                  if (_isRoundTrip) ...[
                    const SizedBox(height: 20),
                    _buildDateSelector(
                      title: 'Return Date',
                      subtitle: 'When do you want to come back?',
                      date: _returnDate,
                      onTap: () => _selectDate(context, false),
                      icon: Icons.flight_land,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Passenger count
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passengers',
                    style: ElegantTheme.sectionTitle,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPassengerSelector(
                    title: 'Adults',
                    subtitle: '12+ years',
                    count: _adults,
                    onIncrement: () => setState(() => _adults++),
                    onDecrement: () => setState(() => _adults = (_adults - 1).clamp(1, 9)),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildPassengerSelector(
                    title: 'Children',
                    subtitle: '2-11 years',
                    count: _children,
                    onIncrement: () => setState(() => _children++),
                    onDecrement: () => setState(() => _children = (_children - 1).clamp(0, 8)),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildPassengerSelector(
                    title: 'Infants',
                    subtitle: 'Under 2 years',
                    count: _infants,
                    onIncrement: () => setState(() => _infants++),
                    onDecrement: () => setState(() => _infants = (_infants - 1).clamp(0, 8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Search flights button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: 'Search Flights',
                onPressed: _canSearch() ? () => _searchFlights() : null,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ElegantTheme.lightAccent : ElegantTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ElegantTheme.lightBlue : ElegantTheme.subtleBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? ElegantTheme.lightBlue : ElegantTheme.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: ElegantTheme.cardTitle.copyWith(
                color: isSelected ? ElegantTheme.lightBlue : ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: ElegantTheme.captionText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String title,
    required String subtitle,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ElegantTheme.softGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ElegantTheme.subtleBorder, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ElegantTheme.lightBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ElegantTheme.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null 
                        ? _formatDate(date)
                        : 'Select date',
                    style: ElegantTheme.bodyText.copyWith(
                      color: date != null ? ElegantTheme.textPrimary : ElegantTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: ElegantTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSelector({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ElegantTheme.cardTitle.copyWith(fontSize: 16),
              ),
              Text(
                subtitle,
                style: ElegantTheme.captionText,
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
              color: ElegantTheme.lightBlue,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: ElegantTheme.cardTitle,
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
              color: ElegantTheme.lightBlue,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate! : _returnDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          // Ensure return date is after departure date
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  bool _canSearch() {
    if (_departureDate == null) return false;
    if (_isRoundTrip && _returnDate == null) return false;
    if (_isRoundTrip && _returnDate!.isBefore(_departureDate!)) return false;
    return true;
  }

  void _searchFlights() {
    if (!_canSearch()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightSearchScreen(
          itinerary: widget.itinerary,
          departureDate: _departureDate!,
          returnDate: _isRoundTrip ? _returnDate : null,
          adults: _adults,
          children: _children,
          infants: _infants,
          originAirport: widget.originAirport,
          destinationAirport: widget.destinationAirport,
        ),
      ),
    );
  }
}

