import 'package:flutter/material.dart';
import '../../widgets/elegant_theme.dart';
import '../../models/flight_models.dart';
import '../../models/saved_trip.dart';
import '../../models/itinerary.dart';
import '../../services/saved_trip_service.dart';
import 'date_selection_screen.dart';
import 'itinerary_selection_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? _selectedOrigin;
  String? _selectedDestination;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final SavedTripService _savedTripService = SavedTripService();
  List<SavedTrip> _savedTrips = [];

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
    Airport(code: 'TRV', name: 'Trivandrum International', city: 'Thiruvananthapuram', country: 'India', timezone: 'Asia/Kolkata'),
    Airport(code: 'IXB', name: 'Bagdogra Airport', city: 'Siliguri', country: 'India', timezone: 'Asia/Kolkata'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTrips() async {
    try {
      final trips = await _savedTripService.getSavedTrips();
      setState(() {
        _savedTrips = trips.cast<SavedTrip>();
      });
    } catch (e) {
      print('Error loading saved trips: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Select Locations',
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
        padding: const EdgeInsets.all(24),
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
                      Text('Choose Your Journey', style: ElegantTheme.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your departure and destination airports to find the best flight deals.',
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Origin Selection
            _buildLocationSelector(
              title: 'From',
              icon: Icons.flight_takeoff,
              controller: _originController,
              selectedCode: _selectedOrigin,
              onTap: () => _showAirportSelector(true),
            ),
            const SizedBox(height: 20),

            // Destination Selection
            _buildLocationSelector(
              title: 'To',
              icon: Icons.flight_land,
              controller: _destinationController,
              selectedCode: _selectedDestination,
              onTap: () => _showAirportSelector(false),
            ),
            const SizedBox(height: 24),

            // Use Saved Trip Button (if available)
            if (_savedTrips.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElegantTheme.createElegantButton(
                  text: 'Use Saved Trip Instead',
                  onPressed: _useSavedTrip,
                  backgroundColor: ElegantTheme.accentOrange,
                  textColor: ElegantTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: 'Continue to Dates',
                onPressed: _canContinue() ? _continueToDates : null,
                backgroundColor: ElegantTheme.accentGreen,
                textColor: ElegantTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ElegantTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ElegantTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(title, style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            Text(
              '${_getAirportByCode(selectedCode)?.city}, ${_getAirportByCode(selectedCode)?.country}',
              style: ElegantTheme.captionText.copyWith(color: ElegantTheme.textSecondary),
            ),
          ],
        ],
      ),
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

  bool _canContinue() {
    return _selectedOrigin != null && 
           _selectedDestination != null && 
           _selectedOrigin != _selectedDestination;
  }

  void _continueToDates() {
    if (!_canContinue()) return;

    // Create a temporary itinerary for the flight search
    final tempItinerary = Itinerary(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Flight from $_selectedOrigin to $_selectedDestination',
      description: 'Flight booking for ${_getAirportByCode(_selectedOrigin!)?.city} to ${_getAirportByCode(_selectedDestination!)?.city}',
      destination: _selectedDestination!,
      startDate: DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
      endDate: DateTime.now().add(const Duration(days: 8)).toIso8601String().split('T')[0],
      travelers: 1,
      itinerary: [],
      totalEstimatedCost: 0.0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSelectionScreen(
          itinerary: tempItinerary,
        ),
      ),
    );
  }

  void _useSavedTrip() {
    // Extract itineraries from saved trips
    final itineraries = _savedTrips
        .map((savedTrip) => savedTrip.itinerary)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItinerarySelectionScreen(
          itineraries: itineraries,
          savedTrips: _savedTrips,
        ),
      ),
    );
  }
}
