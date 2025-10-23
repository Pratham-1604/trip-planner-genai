import 'package:flutter/material.dart';
import '../../models/itinerary.dart';
import '../../models/storytelling_response.dart';
import '../../models/saved_trip.dart';
import '../../widgets/elegant_theme.dart';
import 'date_selection_screen.dart';

class ItinerarySelectionScreen extends StatefulWidget {
  final List<Itinerary> itineraries;
  final List<StorytellingResponse>? storytellingResponses;
  final List<SavedTrip>? savedTrips;

  const ItinerarySelectionScreen({
    super.key,
    required this.itineraries,
    this.storytellingResponses,
    this.savedTrips,
  });

  @override
  State<ItinerarySelectionScreen> createState() => _ItinerarySelectionScreenState();
}

class _ItinerarySelectionScreenState extends State<ItinerarySelectionScreen> {
  Itinerary? _selectedItinerary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Select Your Trip',
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
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: ElegantTheme.primaryBlue,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 48,
                  color: ElegantTheme.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose Your Adventure',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ElegantTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select an itinerary to book flights for your journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: ElegantTheme.white,
                  ),
                ),
              ],
            ),
          ),

          // Itinerary list
          Expanded(
            child: widget.itineraries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.itineraries.length,
                    itemBuilder: (context, index) {
                      final itinerary = widget.itineraries[index];
                      final isSelected = _selectedItinerary?.id == itinerary.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: ElegantTheme.cardDecoration.copyWith(
                          border: Border.all(
                            color: isSelected 
                                ? ElegantTheme.lightBlue 
                                : ElegantTheme.subtleBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedItinerary = itinerary;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? ElegantTheme.lightBlue 
                                            : ElegantTheme.lightAccent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.travel_explore,
                                        color: isSelected 
                                            ? ElegantTheme.white 
                                            : ElegantTheme.lightBlue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itinerary.title,
                                            style: ElegantTheme.cardTitle.copyWith(
                                              color: isSelected 
                                                  ? ElegantTheme.lightBlue 
                                                  : ElegantTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${itinerary.days.length} days • ${itinerary.destination}',
                                            style: ElegantTheme.captionText,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${itinerary.travelers} traveler${itinerary.travelers > 1 ? 's' : ''} • ₹${itinerary.totalEstimatedCost.toStringAsFixed(0)}',
                                            style: ElegantTheme.captionText.copyWith(
                                              color: ElegantTheme.accentGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: ElegantTheme.lightBlue,
                                        size: 24,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  itinerary.description,
                                  style: ElegantTheme.bodyText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: ElegantTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${itinerary.startDate} - ${itinerary.endDate}',
                                      style: ElegantTheme.captionText,
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ElegantTheme.accentGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: ElegantTheme.accentGreen.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${itinerary.travelers} travelers',
                                        style: ElegantTheme.captionText.copyWith(
                                          color: ElegantTheme.accentGreen,
                                          fontWeight: FontWeight.w600,
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
                    },
                  ),
          ),

          // Continue button
          if (_selectedItinerary != null)
            Container(
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
                  text: 'Continue to Flight Search',
                  onPressed: () {
                    // Check if this itinerary has tagged locations
                    final savedTrip = widget.savedTrips?.firstWhere(
                      (trip) => trip.itinerary.id == _selectedItinerary!.id,
                    );
                    
                    if (savedTrip != null && 
                        savedTrip.originAirport != null && 
                        savedTrip.destinationAirport != null) {
                      // Use tagged locations for flight search
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateSelectionScreen(
                            itinerary: _selectedItinerary!,
                            originAirport: savedTrip.originAirport!,
                            destinationAirport: savedTrip.destinationAirport!,
                          ),
                        ),
                      );
                    } else {
                      // Use default locations
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateSelectionScreen(
                            itinerary: _selectedItinerary!,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
        ],
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
              Icons.travel_explore,
              size: 64,
              color: ElegantTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Itineraries Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create an itinerary first to book flights',
              style: TextStyle(
                fontSize: 16,
                color: ElegantTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElegantTheme.createElegantButton(
              text: 'Create Itinerary',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

