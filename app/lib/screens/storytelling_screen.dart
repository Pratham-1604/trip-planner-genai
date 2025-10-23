import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/trip_segment.dart';
import '../models/place.dart';
import '../models/storytelling_response.dart';
import '../models/itinerary.dart';
import '../services/saved_trip_service.dart';
import '../widgets/elegant_theme.dart';
import '../widgets/elegant_activity_card.dart';
import '../widgets/book_page_widget.dart';

class StorytellingScreen extends StatefulWidget {
  final List<TripSegment> tripSegments;
  final StorytellingResponse? storytellingResponse;
  final Itinerary? itinerary;

  const StorytellingScreen({
    super.key,
    required this.tripSegments,
    this.storytellingResponse,
    this.itinerary,
  });

  @override
  State<StorytellingScreen> createState() => _StorytellingScreenState();
}

class _StorytellingScreenState extends State<StorytellingScreen> {
  int _currentPageIndex = 0;
  final SavedTripService _savedTripService = SavedTripService();
  bool _isSaving = false;
  late PageController _pageController;
  late List<BookPage> _bookPages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeBookPages();
  }

  void _initializeBookPages() {
    _bookPages = [];
    
    if (widget.storytellingResponse != null && widget.storytellingResponse!.days.isNotEmpty) {
      // Page 1: Story Introduction
      _bookPages.add(BookPage(
        title: 'Your Adventure Story',
        subtitle: 'The Beginning of Your Journey',
        icon: Icons.auto_stories,
        content: _buildStoryIntroPage(),
      ));

      // Pages for each day
      for (int dayIndex = 0; dayIndex < widget.storytellingResponse!.days.length; dayIndex++) {
        final day = widget.storytellingResponse!.days[dayIndex];
        
        // Day Overview Page
        _bookPages.add(BookPage(
          title: 'Day ${day.day}',
          subtitle: day.title,
          icon: Icons.calendar_today,
          content: _buildDayOverviewPage(day),
        ));

        // Morning Activities Page
        if (day.places.isNotEmpty) {
          _bookPages.add(BookPage(
            title: 'Morning Adventures',
            subtitle: 'Start your day with excitement!',
            icon: Icons.wb_sunny,
            content: _buildMorningActivitiesPage(day),
          ));
        }

        // Afternoon Activities Page
        if (day.places.length > 1) {
          _bookPages.add(BookPage(
            title: 'Afternoon Explorations',
            subtitle: 'Discover more amazing places!',
            icon: Icons.wb_sunny_outlined,
            content: _buildAfternoonActivitiesPage(day),
          ));
        }

        // Evening Activities Page
        if (day.places.length > 2) {
          _bookPages.add(BookPage(
            title: 'Evening Experiences',
            subtitle: 'End your day with memorable moments!',
            icon: Icons.nights_stay,
            content: _buildEveningActivitiesPage(day),
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPageIndex < _bookPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStoryIntroPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: ElegantTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      color: ElegantTheme.lightBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Adventure Story',
                      style: ElegantTheme.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.storytellingResponse!.story,
                  style: ElegantTheme.bodyText.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Journey overview
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ElegantTheme.lightAccent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ElegantTheme.lightBlue.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.explore,
                      color: ElegantTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Journey Overview',
                      style: ElegantTheme.sectionTitle.copyWith(
                        color: ElegantTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.storytellingResponse!.days.length} amazing days of adventure await you! Each day is carefully planned with unique experiences and beautiful destinations.',
                  style: ElegantTheme.bodyText.copyWith(
                    color: ElegantTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOverviewPage(StoryDay day) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: ElegantTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: ElegantTheme.lightBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Day ${day.day} Overview',
                      style: ElegantTheme.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  day.summary,
                  style: ElegantTheme.bodyText.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Places overview
          Container(
            padding: const EdgeInsets.all(24),
            decoration: ElegantTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: ElegantTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Places You\'ll Visit',
                      style: ElegantTheme.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...day.places.map((place) => ElegantPlaceOverview(
                  name: place.name,
                  category: place.category,
                  imageUrl: place.imageUrl,
                  rating: place.rating,
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningActivitiesPage(StoryDay day) {
    final morningPlaces = day.places.take(1).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your day with these amazing adventures:',
            style: ElegantTheme.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...morningPlaces.map((place) => ElegantActivityCard(
            title: place.name,
            description: place.description,
            time: 'Morning',
            imageUrl: place.imageUrl,
            icon: Icons.wb_sunny,
            timeColor: ElegantTheme.accentOrange,
            tags: place.tags,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAfternoonActivitiesPage(StoryDay day) {
    final afternoonPlaces = day.places.skip(1).take(1).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue your adventure in the afternoon:',
            style: ElegantTheme.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...afternoonPlaces.map((place) => ElegantActivityCard(
            title: place.name,
            description: place.description,
            time: 'Afternoon',
            imageUrl: place.imageUrl,
            icon: Icons.wb_sunny_outlined,
            timeColor: ElegantTheme.accentGold,
            tags: place.tags,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEveningActivitiesPage(StoryDay day) {
    final eveningPlaces = day.places.skip(2).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'End your day with these memorable experiences:',
            style: ElegantTheme.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...eveningPlaces.map((place) => ElegantActivityCard(
            title: place.name,
            description: place.description,
            time: 'Evening',
            imageUrl: place.imageUrl,
            icon: Icons.nights_stay,
            timeColor: ElegantTheme.primaryBlue,
            tags: place.tags,
          )).toList(),
        ],
      ),
    );
  }

  Future<void> _saveTrip() async {
    if (widget.itinerary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No itinerary data available to save'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final title = _savedTripService.generateDefaultTitle(widget.itinerary!);
      final description = _savedTripService.generateDefaultDescription(widget.itinerary!);
      
      // Get cover image from first place if available
      String? coverImageUrl;
      if (widget.storytellingResponse?.days.isNotEmpty == true &&
          widget.storytellingResponse!.days.first.places.isNotEmpty) {
        coverImageUrl = widget.storytellingResponse!.days.first.places.first.imageUrl;
      }

      await _savedTripService.saveTrip(
        title: title,
        description: description,
        itinerary: widget.itinerary!,
        storytellingResponse: widget.storytellingResponse,
        coverImageUrl: coverImageUrl,
        tags: ['storytelling', 'visual'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (widget.storytellingResponse == null || widget.storytellingResponse!.days.isEmpty || _bookPages.isEmpty) {
      return Scaffold(
        backgroundColor: ElegantTheme.softGray,
        appBar: AppBar(
          title: const Text(
            'Adventure Story',
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
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: ElegantTheme.cardDecoration,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: ElegantTheme.mediumGray,
                ),
                SizedBox(height: 16),
                Text(
                  'No Adventure Story Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ElegantTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start your journey to create an epic story!',
                  style: TextStyle(
                    fontSize: 16,
                    color: ElegantTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: Text(
          _bookPages.isNotEmpty ? _bookPages[_currentPageIndex].title : 'Adventure Story',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ElegantTheme.white,
          ),
        ),
        backgroundColor: ElegantTheme.primaryBlue,
        foregroundColor: ElegantTheme.white,
        elevation: 0,
        actions: [
          ElegantTheme.createElegantButton(
            text: _isSaving ? 'Saving...' : 'Save',
            onPressed: _isSaving ? () {} : _saveTrip,
            backgroundColor: _isSaving ? ElegantTheme.mediumGray : ElegantTheme.accentGreen,
            textColor: ElegantTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
          ElegantTheme.createElegantButton(
            text: 'Share',
            onPressed: () {
              // TODO: Implement sharing functionality
            },
            backgroundColor: ElegantTheme.accentOrange,
            textColor: ElegantTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Book pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemCount: _bookPages.length,
              itemBuilder: (context, index) {
                final page = _bookPages[index];
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: ElegantTheme.pageDecoration,
                  child: Column(
                    children: [
                      // Page header
                      ElegantPageHeader(
                        title: page.title,
                        subtitle: page.subtitle,
                        icon: page.icon,
                      ),
                      // Page content
                      Expanded(child: page.content),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Book navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElegantTheme.createNavigationBar(
              currentPage: _currentPageIndex,
              totalPages: _bookPages.length,
              onPrevious: _goToPreviousPage,
              onNext: _goToNextPage,
              canGoPrevious: _currentPageIndex > 0,
              canGoNext: _currentPageIndex < _bookPages.length - 1,
            ),
          ),
        ],
      ),
    );
  }




}
