import 'package:flutter/material.dart';
import '../widgets/elegant_theme.dart';
import '../models/hotel_models.dart';
import 'hotel_search_screen.dart';

class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  // Form fields
  String? _selectedLocation;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;
  
  // Controllers
  final TextEditingController _locationController = TextEditingController();
  
  // Popular hotel locations in India
  final List<HotelLocation> _popularLocations = [
    HotelLocation(city: 'Mumbai', state: 'Maharashtra', country: 'India', code: 'BOM', latitude: 19.0760, longitude: 72.8777),
    HotelLocation(city: 'Delhi', state: 'Delhi', country: 'India', code: 'DEL', latitude: 28.7041, longitude: 77.1025),
    HotelLocation(city: 'Bangalore', state: 'Karnataka', country: 'India', code: 'BLR', latitude: 12.9716, longitude: 77.5946),
    HotelLocation(city: 'Chennai', state: 'Tamil Nadu', country: 'India', code: 'MAA', latitude: 13.0827, longitude: 80.2707),
    HotelLocation(city: 'Hyderabad', state: 'Telangana', country: 'India', code: 'HYD', latitude: 17.3850, longitude: 78.4867),
    HotelLocation(city: 'Kolkata', state: 'West Bengal', country: 'India', code: 'CCU', latitude: 22.5726, longitude: 88.3639),
    HotelLocation(city: 'Pune', state: 'Maharashtra', country: 'India', code: 'PNQ', latitude: 18.5204, longitude: 73.8567),
    HotelLocation(city: 'Goa', state: 'Goa', country: 'India', code: 'GOI', latitude: 15.2993, longitude: 74.1240),
    HotelLocation(city: 'Jaipur', state: 'Rajasthan', country: 'India', code: 'JAI', latitude: 26.9124, longitude: 75.7873),
    HotelLocation(city: 'Kochi', state: 'Kerala', country: 'India', code: 'COK', latitude: 9.9312, longitude: 76.2673),
  ];

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Book Hotel',
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
                      Icon(Icons.hotel, color: ElegantTheme.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Text('Find Your Perfect Stay', style: ElegantTheme.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search and compare hotels to get the best deals and amenities.',
                    style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
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
                  Text('Where do you want to stay?', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  _buildLocationSelector(
                    title: 'Destination',
                    icon: Icons.location_on,
                    controller: _locationController,
                    selectedLocation: _selectedLocation,
                    onTap: () => _showLocationSelector(),
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
                  Text('Check-in & Check-out', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  // Check-in date
                  _buildDateSelector(
                    title: 'Check-in Date',
                    subtitle: 'When do you want to arrive?',
                    date: _checkInDate,
                    onTap: () => _selectDate(context, true),
                    icon: Icons.hotel,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildDateSelector(
                    title: 'Check-out Date',
                    subtitle: 'When do you want to leave?',
                    date: _checkOutDate,
                    onTap: () => _selectDate(context, false),
                    icon: Icons.hotel_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Guest & Room Count
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ElegantTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Guests & Rooms', style: ElegantTheme.sectionTitle),
                  const SizedBox(height: 16),
                  
                  _buildGuestSelector(
                    title: 'Adults',
                    subtitle: '18+ years',
                    count: _adults,
                    onIncrement: () => setState(() => _adults++),
                    onDecrement: () => setState(() => _adults = (_adults - 1).clamp(1, 9)),
                  ),
                  
                  const SizedBox(height: 12),
                  _buildGuestSelector(
                    title: 'Children',
                    subtitle: '0-17 years',
                    count: _children,
                    onIncrement: () => setState(() => _children++),
                    onDecrement: () => setState(() => _children = (_children - 1).clamp(0, 8)),
                  ),
                  
                  const SizedBox(height: 12),
                  _buildGuestSelector(
                    title: 'Rooms',
                    subtitle: 'Number of rooms',
                    count: _rooms,
                    onIncrement: () => setState(() => _rooms++),
                    onDecrement: () => setState(() => _rooms = (_rooms - 1).clamp(1, 5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Search Hotels Button
            SizedBox(
              width: double.infinity,
              child: ElegantTheme.createElegantButton(
                text: 'Search Hotels',
                onPressed: _canSearch() ? _searchHotels : null,
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

  Widget _buildLocationSelector({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String? selectedLocation,
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
                    selectedLocation != null 
                        ? _getLocationByCode(selectedLocation)?.displayName ?? 'Select Location'
                        : 'Select Location',
                    style: ElegantTheme.bodyText.copyWith(
                      color: selectedLocation != null ? ElegantTheme.textPrimary : ElegantTheme.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: ElegantTheme.mediumGray),
              ],
            ),
          ),
        ),
        if (selectedLocation != null) ...[
          const SizedBox(height: 4),
          Text(
            _getLocationByCode(selectedLocation)?.fullName ?? '',
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

  Widget _buildGuestSelector({
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

  void _showLocationSelector() {
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
                  Icon(Icons.location_on, color: ElegantTheme.primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  Text('Select Destination', style: ElegantTheme.sectionTitle),
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
                itemCount: _popularLocations.length,
                itemBuilder: (context, index) {
                  final location = _popularLocations[index];
                  final isSelected = _selectedLocation == location.code;
                  
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
                          location.code,
                          style: TextStyle(
                            color: isSelected ? ElegantTheme.white : ElegantTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        location.displayName,
                        style: ElegantTheme.bodyText.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        location.country,
                        style: ElegantTheme.captionText,
                      ),
                      trailing: isSelected 
                          ? Icon(Icons.check_circle, color: ElegantTheme.primaryBlue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLocation = location.code;
                          _locationController.text = location.displayName;
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

  HotelLocation? _getLocationByCode(String code) {
    try {
      return _popularLocations.firstWhere((location) => location.code == code);
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

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate! : _checkOutDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  bool _canSearch() {
    if (_selectedLocation == null) return false;
    if (_checkInDate == null || _checkOutDate == null) return false;
    if (_checkOutDate!.isBefore(_checkInDate!)) return false;
    return true;
  }

  void _searchHotels() {
    if (!_canSearch()) return;

    final request = HotelSearchRequest(
      location: _selectedLocation!,
      checkInDate: _checkInDate!.toIso8601String().split('T')[0],
      checkOutDate: _checkOutDate!.toIso8601String().split('T')[0],
      adults: _adults,
      children: _children > 0 ? _children : null,
      rooms: _rooms,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelSearchScreen(
          searchRequest: request,
        ),
      ),
    );
  }
}
