import 'package:flutter/material.dart';
import '../widgets/elegant_theme.dart';
import '../models/location_guide_models.dart';
import '../models/itinerary.dart';
import '../services/location_guide_service.dart';
import 'location_update_screen.dart';

class LocationGuideScreen extends StatefulWidget {
  final Itinerary itinerary;

  const LocationGuideScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<LocationGuideScreen> createState() => _LocationGuideScreenState();
}

class _LocationGuideScreenState extends State<LocationGuideScreen> {
  final LocationGuideService _guideService = LocationGuideService();
  LocationGuide? _locationGuide;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeLocationGuide();
  }

  Future<void> _initializeLocationGuide() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simple delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));
      final guide = await _guideService.createLocationGuide(widget.itinerary);
      setState(() {
        _locationGuide = guide;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to create location guide. Please try again.';
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
          'Location Guide',
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
            onPressed: _refreshGuide,
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

    if (_locationGuide == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          _buildCurrentStatusCard(),
          const SizedBox(height: 16),

          // Next Steps
          _buildNextStepsSection(),
          const SizedBox(height: 16),

          // Progress Overview
          _buildProgressSection(),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActionsSection(),
        ],
      ),
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
            'Setting up your location guide...',
            style: ElegantTheme.bodyText,
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
              'Failed to Load Guide',
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
              onPressed: _initializeLocationGuide,
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
              Icons.location_on,
              size: 64,
              color: ElegantTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Location Guide Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to create location guide for this itinerary',
              style: ElegantTheme.bodyText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ElegantTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.my_location,
                color: ElegantTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Current Location',
                style: ElegantTheme.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _locationGuide!.currentLocation,
            style: ElegantTheme.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _locationGuide!.currentLocation.toLowerCase().contains('airport') 
                ? 'Welcome! You\'ve arrived at the airport. Ready to start your journey?'
                : _locationGuide!.currentLocation.toLowerCase().contains('hotel')
                    ? 'Welcome! You\'ve checked into your hotel. Ready to explore?'
                    : 'Last updated: ${_formatDateTime(_locationGuide!.lastUpdated)}',
            style: ElegantTheme.captionText,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChip('Day ${_locationGuide!.currentDayIndex + 1}'),
              const SizedBox(width: 8),
              _buildStatusChip('Step ${_locationGuide!.currentActivityIndex + 1}'),
              const SizedBox(width: 8),
              _buildStatusChip(_locationGuide!.status.name.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ElegantTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ElegantTheme.lightBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: ElegantTheme.captionText.copyWith(
          color: ElegantTheme.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNextStepsSection() {
    if (_locationGuide!.upcomingSteps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: ElegantTheme.cardDecoration,
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: ElegantTheme.accentGreen,
            ),
            const SizedBox(height: 12),
            const Text(
              'All Steps Completed!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have completed all the planned activities. Great job!',
              style: ElegantTheme.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final nextStep = _locationGuide!.upcomingSteps.first;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ElegantTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.navigate_next,
                color: ElegantTheme.accentGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Next Step',
                style: ElegantTheme.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepCard(nextStep, isNext: true),
        ],
      ),
    );
  }

  Widget _buildStepCard(GuideStep step, {bool isNext = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? ElegantTheme.accentGreen.withOpacity(0.1) : ElegantTheme.softGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? ElegantTheme.accentGreen.withOpacity(0.3) : ElegantTheme.subtleBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: ElegantTheme.cardTitle.copyWith(
                    color: isNext ? ElegantTheme.accentGreen : ElegantTheme.textPrimary,
                  ),
                ),
              ),
              if (isNext)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ElegantTheme.accentGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: ElegantTheme.bodyText,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: ElegantTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  step.address,
                  style: ElegantTheme.captionText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: ElegantTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                step.formattedScheduledTime,
                style: ElegantTheme.captionText,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.timer,
                size: 16,
                color: ElegantTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                step.formattedDuration,
                style: ElegantTheme.captionText,
              ),
            ],
          ),
          if (step.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Tips:',
              style: ElegantTheme.captionText.copyWith(
                fontWeight: FontWeight.w600,
                color: ElegantTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            ...step.tips.take(2).map((tip) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: ElegantTheme.captionText),
                  Expanded(
                    child: Text(
                      tip,
                      style: ElegantTheme.captionText,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalSteps = _locationGuide!.completedSteps.length + _locationGuide!.upcomingSteps.length;
    final completedSteps = _locationGuide!.completedSteps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ElegantTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: ElegantTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Progress',
                style: ElegantTheme.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${completedSteps} of $totalSteps steps completed',
                      style: ElegantTheme.bodyText,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: ElegantTheme.softGray,
                      valueColor: AlwaysStoppedAnimation<Color>(ElegantTheme.accentGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(progress * 100).toInt()}%',
                style: ElegantTheme.cardTitle.copyWith(
                  color: ElegantTheme.accentGreen,
                ),
              ),
            ],
          ),
          if (completedSteps > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Recently Completed:',
              style: ElegantTheme.captionText.copyWith(
                fontWeight: FontWeight.w600,
                color: ElegantTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            ..._locationGuide!.completedSteps.take(3).map((step) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ElegantTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ElegantTheme.accentGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: ElegantTheme.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.title,
                      style: ElegantTheme.captionText.copyWith(
                        color: ElegantTheme.accentGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ElegantTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: ElegantTheme.sectionTitle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.my_location,
                  label: 'Update Location',
                  color: ElegantTheme.primaryBlue,
                  onTap: _updateLocation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.directions,
                  label: 'Get Directions',
                  color: ElegantTheme.accentGreen,
                  onTap: _getDirections,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Mark Complete',
                  color: ElegantTheme.accentOrange,
                  onTap: _markStepComplete,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.insights,
                  label: 'Recommendations',
                  color: ElegantTheme.accentGold,
                  onTap: _showRecommendations,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: ElegantTheme.captionText.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _refreshGuide() {
    _initializeLocationGuide();
  }

  void _updateLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationUpdateScreen(
          locationGuide: _locationGuide!,
          onLocationUpdated: (updatedGuide) {
            setState(() {
              _locationGuide = updatedGuide;
            });
          },
        ),
      ),
    );
  }

  void _getDirections() {
    if (_locationGuide!.upcomingSteps.isNotEmpty) {
      final nextStep = _locationGuide!.upcomingSteps.first;
      // TODO: Implement directions functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Getting directions to ${nextStep.title}'),
          backgroundColor: ElegantTheme.lightBlue,
        ),
      );
    }
  }

  void _markStepComplete() async {
    if (_locationGuide!.upcomingSteps.isNotEmpty) {
      final nextStep = _locationGuide!.upcomingSteps.first;
      final messenger = ScaffoldMessenger.of(context);
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedGuide = await _guideService.markStepCompleted(
          _locationGuide!.id,
          nextStep.id,
          _locationGuide!,
        );
        
        if (mounted) {
          setState(() {
            _locationGuide = updatedGuide;
            _isLoading = false;
          });
          
          messenger.showSnackBar(
            SnackBar(
              content: Text('Marked ${nextStep.title} as complete!'),
              backgroundColor: ElegantTheme.accentGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to mark step as complete: $e'),
              backgroundColor: ElegantTheme.accentOrange,
            ),
          );
        }
      }
    }
  }

  void _showRecommendations() {
    if (_locationGuide!.upcomingSteps.isNotEmpty) {
      final nextStep = _locationGuide!.upcomingSteps.first;
      // TODO: Implement recommendations functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Getting recommendations for ${nextStep.title}'),
          backgroundColor: ElegantTheme.accentGold,
        ),
      );
    }
  }
}
