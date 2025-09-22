import 'package:flutter/material.dart';
import '../../models/saved_trip.dart';
import '../../models/flight_models.dart';
import '../../widgets/elegant_theme.dart';

class LocationTaggingScreen extends StatefulWidget {
  final SavedTrip savedTrip;
  final Function(SavedTrip) onLocationTagged;

  const LocationTaggingScreen({
    super.key,
    required this.savedTrip,
    required this.onLocationTagged,
  });

  @override
  State<LocationTaggingScreen> createState() => _LocationTaggingScreenState();
}

class _LocationTaggingScreenState extends State<LocationTaggingScreen> {
  String? _selectedOrigin;
  String? _selectedDestination;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _isLoading = false;

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
    _initializeLocations();
  }

  void _initializeLocations() {
    if (widget.savedTrip.originAirport != null) {
      _selectedOrigin = widget.savedTrip.originAirport!.code;
      _originController.text = widget.savedTrip.originAirport!.name;
    }
    if (widget.savedTrip.destinationAirport != null) {
      _selectedDestination = widget.savedTrip.destinationAirport!.code;
      _destinationController.text = widget.savedTrip.destinationAirport!.name;
    }
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
          'Tag Locations',
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
            // Trip Info Card
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
                      Text('Trip Information', style: ElegantTheme.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.savedTrip.title,
                    style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.savedTrip.description,
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: ElegantTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.savedTrip.itinerary.days.length} days',
                        style: ElegantTheme.captionText,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: ElegantTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.savedTrip.itinerary.travelers} traveler${widget.savedTrip.itinerary.travelers > 1 ? 's' : ''}',
                        style: ElegantTheme.captionText,
                      ),
                    ],
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
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: _isLoading ? 'Saving...' : 'Save Locations',
                onPressed: _isLoading ? null : _saveLocations,
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

  void _saveLocations() async {
    if (_selectedOrigin == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both origin and destination airports'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedOrigin == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated saved trip with location information
      final updatedTrip = widget.savedTrip.copyWith(
        originLocation: _getAirportByCode(_selectedOrigin!)?.city,
        destinationLocation: _getAirportByCode(_selectedDestination!)?.city,
        originAirport: _getAirportByCode(_selectedOrigin!),
        destinationAirport: _getAirportByCode(_selectedDestination!),
        updatedAt: DateTime.now(),
      );

      // Call the callback to update the parent
      widget.onLocationTagged(updatedTrip);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Locations saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
