import 'package:flutter/material.dart';
import '../widgets/elegant_theme.dart';
import '../models/flight_models.dart';
import '../models/itinerary.dart';
import 'flight_booking/flight_search_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  // Form fields
  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = true;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  
  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  // Popular airports in India
  final List<Airport> _popularAirports = [
    Airport(code: 'DEL', name: 'Indira Gandhi International', city: 'Delhi', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'BOM', name: 'Chhatrapati Shivaji Maharaj International', city: 'Mumbai', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'BLR', name: 'Kempegowda International', city: 'Bangalore', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'MAA', name: 'Chennai International', city: 'Chennai', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'HYD', name: 'Rajiv Gandhi International', city: 'Hyderabad', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'CCU', name: 'Netaji Subhash Chandra Bose International', city: 'Kolkata', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'AMD', name: 'Sardar Vallabhbhai Patel International', city: 'Ahmedabad', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'PNQ', name: 'Pune International', city: 'Pune', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'GOI', name: 'Dabolim Airport', city: 'Goa', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'COK', name: 'Cochin International', city: 'Kochi', country: 'India', timezone: 'Asia/Kolkata'),
  ];

  @override
  void initState() {
    super.initState();
    _departureDate = DateTime.now().add(const Duration(days: 1));
    _returnDate = DateTime.now().add(const Duration(days: 8));
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Book Flight',
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: ElegantTheme.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Text('Find Your Perfect Flight', style: ElegantTheme.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search and compare flights from top airlines to get the best deals.',
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trip Type Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Type', style: ElegantTheme.sectionTitle),
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

            // Location Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From & To', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  // Origin Selection
                  _buildLocationSelector(
                    title: 'From',
                    icon: Icons.flight_takeoff,
                    controller: _originController,
                    selectedCode: _selectedOrigin,
                    onTap: () => _showAirportSelector(true),
                  ),
                  const SizedBox(height: 16),
                  
                  // Destination Selection
                  _buildLocationSelector(
                    title: 'To',
                    icon: Icons.flight_land,
                    controller: _destinationController,
                    selectedCode: _selectedDestination,
                    onTap: () => _showAirportSelector(false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Travel Dates', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  // Departure date
                  _buildDateSelector(
                    title: 'Departure Date',
                    subtitle: 'When do you want to leave?',
                    date: _departureDate,
                    onTap: () => _selectDate(context, true),
                    icon: Icons.flight_takeoff,
                  ),
                  
                  if (_isRoundTrip) ...[
                    const SizedBox(height: 16),
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

            // Passenger Count
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passengers', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  _buildPassengerSelector(
                    title: 'Adults',
                    subtitle: '12+ years',
                    count: _adults,
                    onIncrement: () => setState(() => _adults++),
                    onDecrement: () => setState(() => _adults = (_adults - 1).clamp(1, 9)),
                  ),
                  
                  const SizedBox(height: 12),
                  _buildPassengerSelector(
                    title: 'Children',
                    subtitle: '2-11 years',
                    count: _children,
                    onIncrement: () => setState(() => _children++),
                    onDecrement: () => setState(() => _children = (_children - 1).clamp(0, 8)),
                  ),
                  
                  const SizedBox(height: 12),
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

            // Search Flights Button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: 'Search Flights',
                onPressed: _canSearch() ? _searchFlights : null,
                backgroundColor: ElegantTheme.accentGreen,
                textColor: ElegantTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildLocationSelector({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String? selectedCode,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ElegantTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(title, style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: ElegantTheme.mediumGray.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
              color: ElegantTheme.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCode != null 
                        ? _getAirportByCode(selectedCode)?.name ?? 'Select Airport'
                        : 'Select Airport',
                    style: ElegantTheme.bodyText.copyWith(
                      color: selectedCode != null ? ElegantTheme.textPrimary : ElegantTheme.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: ElegantTheme.mediumGray),
              ],
            ),
          ),
        ),
        if (selectedCode != null) ...[
          const SizedBox(height: 4),
          Text(
            '${_getAirportByCode(selectedCode)?.city}, ${_getAirportByCode(selectedCode)?.country}',
            style: ElegantTheme.captionText.copyWith(color: ElegantTheme.textSecondary),
          ),
        ],
      ],
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
            Icon(icon, color: ElegantTheme.lightBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ElegantTheme.cardTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _formatDate(date) : 'Select date',
                    style: ElegantTheme.bodyText.copyWith(
                      color: date != null ? ElegantTheme.textPrimary : ElegantTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today, color: ElegantTheme.textSecondary, size: 20),
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
              Text(title, style: ElegantTheme.cardTitle.copyWith(fontSize: 16)),
              Text(subtitle, style: ElegantTheme.captionText),
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
              child: Text(count.toString(), style: ElegantTheme.cardTitle),
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

  void _showAirportSelector(bool isOrigin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: ElegantTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElegantTheme.softGray,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    isOrigin ? Icons.flight_takeoff : Icons.flight_land,
                    color: ElegantTheme.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select ${isOrigin ? 'Origin' : 'Destination'} Airport',
                    style: ElegantTheme.sectionTitle,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _popularAirports.length,
                itemBuilder: (context, index) {
                  final airport = _popularAirports[index];
                  final isSelected = isOrigin 
                      ? _selectedOrigin == airport.code
                      : _selectedDestination == airport.code;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: isSelected ? 3 : 1,
                    color: isSelected ? ElegantTheme.lightBlue.withOpacity(0.1) : ElegantTheme.white,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? ElegantTheme.primaryBlue : ElegantTheme.softGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          airport.code,
                          style: TextStyle(
                            color: isSelected ? ElegantTheme.white : ElegantTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        airport.name,
                        style: ElegantTheme.bodyText.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${airport.city}, ${airport.country}',
                        style: ElegantTheme.captionText,
                      ),
                      trailing: isSelected 
                          ? Icon(Icons.check_circle, color: ElegantTheme.primaryBlue)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isOrigin) {
                            _selectedOrigin = airport.code;
                            _originController.text = airport.name;
                          } else {
                            _selectedDestination = airport.code;
                            _destinationController.text = airport.name;
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Airport? _getAirportByCode(String code) {
    try {
      return _popularAirports.firstWhere((airport) => airport.code == code);
    } catch (e) {
      return null;
    }
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
    if (_selectedOrigin == null || _selectedDestination == null) return false;
    if (_selectedOrigin == _selectedDestination) return false;
    if (_departureDate == null) return false;
    if (_isRoundTrip && _returnDate == null) return false;
    if (_isRoundTrip && _returnDate!.isBefore(_departureDate!)) return false;
    return true;
  }

  void _searchFlights() {
    if (!_canSearch()) return;

    // Create a temporary itinerary for the flight search
    final tempItinerary = Itinerary(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Flight from $_selectedOrigin to $_selectedDestination',
      description: 'Flight booking for ${_getAirportByCode(_selectedOrigin!)?.city} to ${_getAirportByCode(_selectedDestination!)?.city}',
      destination: _selectedDestination!,
      startDate: _departureDate!.toIso8601String().split('T')[0],
      endDate: _isRoundTrip ? _returnDate!.toIso8601String().split('T')[0] : _departureDate!.toIso8601String().split('T')[0],
      travelers: _adults + _children + _infants,
      itinerary: [],
      totalEstimatedCost: 0.0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightSearchScreen(
          itinerary: tempItinerary,
          departureDate: _departureDate!,
          returnDate: _isRoundTrip ? _returnDate : null,
          adults: _adults,
          children: _children,
          infants: _infants,
          originAirport: _getAirportByCode(_selectedOrigin!),
          destinationAirport: _getAirportByCode(_selectedDestination!),
        ),
      ),
    );
  }
}
