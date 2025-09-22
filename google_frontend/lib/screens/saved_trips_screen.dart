import 'package:flutter/material.dart';
import '../models/saved_trip.dart';
import '../services/saved_trip_service.dart';
import '../services/storytelling_service.dart';
import '../services/pdf_service.dart';
import '../widgets/elegant_theme.dart';
import 'storytelling_screen.dart';
import 'flight_booking/location_tagging_screen.dart';
import 'location_guide_screen.dart';

class SavedTripsScreen extends StatefulWidget {
  const SavedTripsScreen({super.key});

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  final SavedTripService _savedTripService = SavedTripService();
  final StorytellingService _storytellingService = StorytellingService();
  final PDFService _pdfService = PDFService();
  List<SavedTrip> _savedTrips = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? _generatingStoryForTripId;
  String? _downloadingPDFForTripId;

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  Future<void> _loadSavedTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trips = await _savedTripService.getSavedTrips();
      setState(() {
        _savedTrips = trips.cast<SavedTrip>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading saved trips: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<SavedTrip> get _filteredTrips {
    var filtered = _savedTrips;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((trip) {
        return trip.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               trip.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               trip.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'With Locations':
        filtered = filtered.where((trip) => 
          trip.originAirport != null && trip.destinationAirport != null).toList();
        break;
      case 'Without Locations':
        filtered = filtered.where((trip) => 
          trip.originAirport == null || trip.destinationAirport == null).toList();
        break;
      case 'Recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'My Saved Trips',
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedTrips,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: ElegantTheme.white,
              child: Column(
                children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search trips...',
                    prefixIcon: const Icon(Icons.search, color: ElegantTheme.mediumGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ElegantTheme.mediumGray.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ElegantTheme.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('With Locations'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Without Locations'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Recent'),
                    ],
                  ),
                  ),
                ],
              ),
          ),
          // Trips List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTrips.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _filteredTrips[index];
                          return _buildTripCard(trip);
                        },
                    ),
                  ),
                ],
              ),
            );
          }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: ElegantTheme.lightBlue.withOpacity(0.2),
      checkmarkColor: ElegantTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? ElegantTheme.primaryBlue : ElegantTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.flight_takeoff,
              size: 80,
              color: ElegantTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No trips found for "$_searchQuery"'
                  : 'No saved trips yet',
              style: ElegantTheme.sectionTitle.copyWith(color: ElegantTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Start planning your next adventure!',
              style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(SavedTrip trip) {
    final hasLocations = trip.originAirport != null && trip.destinationAirport != null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewTripDetails(trip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and location status
              Row(
                children: [
                  Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        Text(
                          trip.title,
                          style: ElegantTheme.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.description,
                          style: ElegantTheme.bodyText.copyWith(color: ElegantTheme.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Location status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasLocations 
                          ? ElegantTheme.accentGreen.withOpacity(0.1)
                          : ElegantTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasLocations 
                            ? ElegantTheme.accentGreen
                            : ElegantTheme.accentOrange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasLocations ? Icons.location_on : Icons.location_off,
                          size: 14,
                          color: hasLocations 
                              ? ElegantTheme.accentGreen
                              : ElegantTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasLocations ? 'Tagged' : 'No Locations',
                          style: ElegantTheme.captionText.copyWith(
                            color: hasLocations 
                                ? ElegantTheme.accentGreen
                                : ElegantTheme.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 12),
              
              // Location info (if available)
              if (hasLocations) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ElegantTheme.lightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ElegantTheme.lightBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flight_takeoff, size: 16, color: ElegantTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        '${trip.originAirport!.city} (${trip.originAirport!.code})',
                        style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16, color: ElegantTheme.mediumGray),
                      const SizedBox(width: 8),
                      Text(
                        '${trip.destinationAirport!.city} (${trip.destinationAirport!.code})',
                        style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                  const SizedBox(height: 12),
              ],
              
              // Trip details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: ElegantTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.itinerary.days.length} days',
                    style: ElegantTheme.captionText,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: ElegantTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.itinerary.travelers} traveler${trip.itinerary.travelers > 1 ? 's' : ''}',
                    style: ElegantTheme.captionText,
                  ),
                  const Spacer(),
                  Text(
                    '₹${trip.itinerary.totalEstimatedCost.toStringAsFixed(0)}',
                    style: ElegantTheme.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                      color: ElegantTheme.accentGreen,
                    ),
                  ),
                ],
              ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _viewItinerary(trip),
                          icon: const Icon(Icons.list_alt, size: 16),
                          label: const Text('View Itinerary'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _startLocationGuide(trip),
                          icon: const Icon(Icons.navigation, size: 16),
                          label: const Text('Start Guide'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElegantTheme.accentGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                        Expanded(
                          child: ElevatedButton.icon(
                      onPressed: () => _tagLocations(trip),
                      icon: Icon(
                        hasLocations ? Icons.edit_location : Icons.add_location,
                        size: 16,
                      ),
                      label: Text(hasLocations ? 'Edit Locations' : 'Tag Locations'),
                            style: ElevatedButton.styleFrom(
                        backgroundColor: hasLocations 
                            ? ElegantTheme.primaryBlue 
                            : ElegantTheme.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatingStoryForTripId == trip.id ? null : () => _generateVisualStory(trip),
                          icon: _generatingStoryForTripId == trip.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  trip.storytellingResponse != null ? Icons.visibility : Icons.auto_stories,
                                  size: 16,
                                ),
                          label: Text(
                            _generatingStoryForTripId == trip.id
                                ? 'Generating...'
                                : trip.storytellingResponse != null 
                                    ? 'View Story' 
                                    : 'Generate Story',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: trip.storytellingResponse != null 
                                ? ElegantTheme.accentGold 
                                : ElegantTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadingPDFForTripId == trip.id ? null : () => _downloadItineraryPDF(trip),
                          icon: _downloadingPDFForTripId == trip.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.download, size: 16),
                          label: Text(
                            _downloadingPDFForTripId == trip.id ? 'Saving...' : 'Save Itinerary',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElegantTheme.accentGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: trip.storytellingResponse != null && _downloadingPDFForTripId != trip.id
                              ? () => _downloadStoryPDF(trip)
                              : null,
                          icon: _downloadingPDFForTripId == trip.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf, size: 16),
                          label: Text(
                            _downloadingPDFForTripId == trip.id 
                                ? 'Saving...' 
                                : trip.storytellingResponse != null 
                                    ? 'Save Story' 
                                    : 'No Story',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: trip.storytellingResponse != null 
                                ? ElegantTheme.accentOrange 
                                : ElegantTheme.mediumGray,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadingPDFForTripId == trip.id ? null : () => _shareItineraryPDF(trip),
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share Itinerary'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElegantTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: trip.storytellingResponse != null && _downloadingPDFForTripId != trip.id
                              ? () => _shareStoryPDF(trip)
                              : null,
                          icon: const Icon(Icons.share, size: 16),
                          label: Text(
                            trip.storytellingResponse != null ? 'Share Story' : 'No Story',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: trip.storytellingResponse != null 
                                ? ElegantTheme.accentGold 
                                : ElegantTheme.mediumGray,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

  void _viewTripDetails(SavedTrip trip) {
    if (trip.storytellingResponse != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorytellingScreen(
            storytellingResponse: trip.storytellingResponse!,
            tripSegments: [], // Empty trip segments for saved trips
          ),
        ),
      );
    } else {
      _viewItinerary(trip);
    }
  }

  void _viewItinerary(SavedTrip trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ElegantTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                children: [
                    const Icon(Icons.list_alt, color: ElegantTheme.white, size: 24),
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      trip.title,
                        style: ElegantTheme.sectionTitle.copyWith(
                          color: ElegantTheme.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: ElegantTheme.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Itinerary Details',
                        style: ElegantTheme.sectionTitle,
              ),
              const SizedBox(height: 16),
                      ...trip.itinerary.days.map((day) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: ElegantTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day ${day.day}',
                                style: ElegantTheme.bodyText.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ElegantTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (day.morning.isNotEmpty) ...[
                                _buildActivitySection('Morning', day.morning, Icons.wb_sunny),
                                const SizedBox(height: 8),
                              ],
                              if (day.afternoon.isNotEmpty) ...[
                                _buildActivitySection('Afternoon', day.afternoon, Icons.wb_sunny_outlined),
                                const SizedBox(height: 8),
                              ],
                              if (day.evening.isNotEmpty) ...[
                                _buildActivitySection('Evening', day.evening, Icons.nights_stay),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated Cost: ₹${day.estimatedCost.toStringAsFixed(0)}',
                                    style: ElegantTheme.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ElegantTheme.accentGreen,
                                    ),
                                  ),
                                  if (day.note != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ElegantTheme.lightBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Note: ${day.note}',
                                        style: ElegantTheme.captionText,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ElegantTheme.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ElegantTheme.accentGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Estimated Cost',
                              style: ElegantTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '₹${trip.itinerary.totalEstimatedCost.toStringAsFixed(0)}',
                              style: ElegantTheme.sectionTitle.copyWith(color: ElegantTheme.accentGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ElegantTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ElegantTheme.captionText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ElegantTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: ElegantTheme.bodyText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startLocationGuide(SavedTrip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationGuideScreen(
          itinerary: trip.itinerary,
        ),
      ),
    );
  }

  void _generateVisualStory(SavedTrip trip) async {
    if (trip.storytellingResponse != null) {
      // View existing story
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorytellingScreen(
            storytellingResponse: trip.storytellingResponse!,
            tripSegments: [], // Empty trip segments for saved trips
          ),
        ),
      );
    } else {
      // Generate new story from API
      setState(() {
        _generatingStoryForTripId = trip.id;
      });

      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                const Text('Generating visual story...'),
              ],
            ),
          ),
        );

        // Generate storytelling from API
        final storytellingResponse = await _storytellingService.generateStorytellingExperience(trip.itinerary);
        
        // Generate trip segments from the storytelling response
        final tripSegments = _storytellingService.generateTripSegmentsFromStorytelling(storytellingResponse);

        // Save the generated story to Firebase
        await _savedTripService.updateSavedTrip(
          tripId: trip.id,
          storytellingResponse: storytellingResponse,
        );

        // Update the local trip data
        setState(() {
          final tripIndex = _savedTrips.indexWhere((t) => t.id == trip.id);
          if (tripIndex != -1) {
            _savedTrips[tripIndex] = SavedTrip(
              id: trip.id,
              userId: trip.userId,
              title: trip.title,
              description: trip.description,
              itinerary: trip.itinerary,
              storytellingResponse: storytellingResponse,
              createdAt: trip.createdAt,
              updatedAt: DateTime.now(),
              tags: trip.tags,
              coverImageUrl: trip.coverImageUrl,
              originLocation: trip.originLocation,
              destinationLocation: trip.destinationLocation,
              originAirport: trip.originAirport,
              destinationAirport: trip.destinationAirport,
            );
          }
        });

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Visual story generated and saved successfully!'),
              backgroundColor: ElegantTheme.accentGreen,
            ),
          );
        }

        // Navigate to storytelling screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StorytellingScreen(
                storytellingResponse: storytellingResponse,
                tripSegments: tripSegments,
              ),
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate story: $e'),
              backgroundColor: ElegantTheme.accentOrange,
            ),
          );
        }
      } finally {
        setState(() {
          _generatingStoryForTripId = null;
        });
      }
    }
  }


  void _downloadItineraryPDF(SavedTrip trip) async {
    setState(() {
      _downloadingPDFForTripId = trip.id;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Generating itinerary PDF...'),
            ],
          ),
        ),
      );

      // Generate PDF
      final pdfBytes = await _pdfService.generateItineraryPDF(trip);
      
      // Save to device
      final fileName = '${trip.title.replaceAll(' ', '_')}_Itinerary';
      final filePath = await _pdfService.savePDFToDevice(pdfBytes, fileName);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Itinerary PDF saved to: $filePath'),
            backgroundColor: ElegantTheme.accentGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: ElegantTheme.accentOrange,
          ),
        );
      }
    } finally {
      setState(() {
        _downloadingPDFForTripId = null;
      });
    }
  }

  void _downloadStoryPDF(SavedTrip trip) async {
    if (trip.storytellingResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No visual story available for this trip'),
          backgroundColor: ElegantTheme.accentOrange,
        ),
      );
      return;
    }

    setState(() {
      _downloadingPDFForTripId = trip.id;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Generating story PDF...'),
            ],
          ),
        ),
      );

      // Generate PDF
      final pdfBytes = await _pdfService.generateStoryPDF(trip);
      
      // Save to device
      final fileName = '${trip.title.replaceAll(' ', '_')}_Story';
      final filePath = await _pdfService.savePDFToDevice(pdfBytes, fileName);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Story PDF saved to: $filePath'),
            backgroundColor: ElegantTheme.accentGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: ElegantTheme.accentOrange,
          ),
        );
      }
    } finally {
      setState(() {
        _downloadingPDFForTripId = null;
      });
    }
  }

  void _shareItineraryPDF(SavedTrip trip) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Generating itinerary PDF...'),
            ],
          ),
        ),
      );

      // Generate PDF
      final pdfBytes = await _pdfService.generateItineraryPDF(trip);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Share PDF
      final fileName = '${trip.title.replaceAll(' ', '_')}_Itinerary';
      await _pdfService.sharePDF(pdfBytes, fileName);

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: ElegantTheme.accentOrange,
          ),
        );
      }
    }
  }

  void _shareStoryPDF(SavedTrip trip) async {
    if (trip.storytellingResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No visual story available for this trip'),
          backgroundColor: ElegantTheme.accentOrange,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Generating story PDF...'),
            ],
          ),
        ),
      );

      // Generate PDF
      final pdfBytes = await _pdfService.generateStoryPDF(trip);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Share PDF
      final fileName = '${trip.title.replaceAll(' ', '_')}_Story';
      await _pdfService.sharePDF(pdfBytes, fileName);

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: ElegantTheme.accentOrange,
          ),
        );
      }
    }
  }

  void _tagLocations(SavedTrip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationTaggingScreen(
          savedTrip: trip,
          onLocationTagged: (updatedTrip) {
            setState(() {
              final index = _savedTrips.indexWhere((t) => t.id == updatedTrip.id);
              if (index != -1) {
                _savedTrips[index] = updatedTrip;
              }
            });
          },
        ),
      ),
    );
  }
}