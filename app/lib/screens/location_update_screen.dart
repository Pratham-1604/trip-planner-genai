import 'package:flutter/material.dart';
import '../widgets/elegant_theme.dart';
import '../models/location_guide_models.dart';
import '../services/location_guide_service.dart';

class LocationUpdateScreen extends StatefulWidget {
  final LocationGuide locationGuide;
  final Function(LocationGuide) onLocationUpdated;

  const LocationUpdateScreen({
    super.key,
    required this.locationGuide,
    required this.onLocationUpdated,
  });

  @override
  State<LocationUpdateScreen> createState() => _LocationUpdateScreenState();
}

class _LocationUpdateScreenState extends State<LocationUpdateScreen> {
  final LocationGuideService _guideService = LocationGuideService();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedLocation;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isUpdating = false;

  // Popular locations for quick selection
  final List<Map<String, dynamic>> _popularLocations = [
    {
      'name': 'Gateway of India',
      'address': 'Apollo Bandar, Colaba, Mumbai, Maharashtra 400001',
      'latitude': 18.9220,
      'longitude': 72.8347,
    },
    {
      'name': 'Marine Drive',
      'address': 'Marine Drive, Mumbai, Maharashtra 400020',
      'latitude': 18.9440,
      'longitude': 72.8250,
    },
    {
      'name': 'Colaba Causeway',
      'address': 'Colaba Causeway, Mumbai, Maharashtra 400005',
      'latitude': 18.9220,
      'longitude': 72.8347,
    },
    {
      'name': 'Juhu Beach',
      'address': 'Juhu Beach, Mumbai, Maharashtra 400049',
      'latitude': 19.1074,
      'longitude': 72.8263,
    },
    {
      'name': 'Bandra-Worli Sea Link',
      'address': 'Bandra-Worli Sea Link, Mumbai, Maharashtra',
      'latitude': 19.0330,
      'longitude': 72.8200,
    },
    {
      'name': 'Red Fort',
      'address': 'Netaji Subhash Marg, Lal Qila, Old Delhi, Delhi 110006',
      'latitude': 28.6562,
      'longitude': 77.2410,
    },
    {
      'name': 'India Gate',
      'address': 'Rajpath, India Gate, New Delhi, Delhi 110003',
      'latitude': 28.6129,
      'longitude': 77.2295,
    },
    {
      'name': 'Lotus Temple',
      'address': 'Lotus Temple Rd, Bahapur, Shambhu Dayal Bagh, New Delhi, Delhi 110019',
      'latitude': 28.5535,
      'longitude': 77.2588,
    },
  ];

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.locationGuide.currentLocation;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Update Location',
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
                      Icon(Icons.my_location, color: ElegantTheme.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Text('Where are you now?', style: ElegantTheme.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Update your current location to get personalized recommendations and directions.',
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current Location
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Location', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location Name',
                      hintText: 'e.g., Gateway of India',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address (Optional)',
                      hintText: 'Full address of your location',
                      prefixIcon: const Icon(Icons.home),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Any additional notes about your location',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Location Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Select', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  Text(
                    'Tap on a popular location to quickly update your position:',
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularLocations.map((location) {
                      final isSelected = _selectedLocation == location['name'];
                      return InkWell(
                        onTap: () => _selectLocation(location),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? ElegantTheme.primaryBlue 
                                : ElegantTheme.softGray,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? ElegantTheme.primaryBlue 
                                  : ElegantTheme.subtleBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            location['name'],
                            style: ElegantTheme.captionText.copyWith(
                              color: isSelected 
                                  ? ElegantTheme.white 
                                  : ElegantTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location Details (if selected)
            if (_selectedLocation != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: ElegantTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Location', style: ElegantTheme.sectionTitle),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: ElegantTheme.accentGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLocation!,
                            style: ElegantTheme.cardTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.home, color: ElegantTheme.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _addressController.text.isNotEmpty 
                                ? _addressController.text 
                                : 'Address not specified',
                            style: ElegantTheme.captionText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.my_location, color: ElegantTheme.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}',
                          style: ElegantTheme.captionText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: _isUpdating ? 'Updating...' : 'Update Location',
                onPressed: _canUpdate() && !_isUpdating ? _updateLocation : null,
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

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _selectedLocation = location['name'];
      _locationController.text = location['name'];
      _addressController.text = location['address'];
      _latitude = location['latitude'];
      _longitude = location['longitude'];
    });
  }

  bool _canUpdate() {
    return _locationController.text.isNotEmpty && 
           _selectedLocation != null &&
           _latitude != 0.0 && 
           _longitude != 0.0;
  }

  Future<void> _updateLocation() async {
    if (!_canUpdate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedGuide = await _guideService.updateCurrentLocation(
        widget.locationGuide.id,
        _locationController.text,
        _addressController.text,
        _latitude,
        _longitude,
        _notesController.text,
      );

      widget.onLocationUpdated(updatedGuide);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated to ${_locationController.text}'),
            backgroundColor: ElegantTheme.accentGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location: $e'),
            backgroundColor: ElegantTheme.accentOrange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}
