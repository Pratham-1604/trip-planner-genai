import 'package:flutter/material.dart';
import 'package:google_frontend/models/storytelling_response.dart';
import '../models/chat_message.dart';
import '../models/itinerary.dart';
import '../services/trip_service.dart';
import '../services/storytelling_service.dart';
import '../services/saved_trip_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/itinerary_summary.dart';
import '../widgets/itinerary_card.dart';
import 'storytelling_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TripService _tripService = TripService();
  final StorytellingService _storytellingService = StorytellingService();
  final SavedTripService _savedTripService = SavedTripService();
  bool _isLoading = false;
  String? _pendingClarificationInput;
  Map<String, bool> _savingTrips = {}; // Track which trips are being saved

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        content: 'Hi! I\'m your AI travel planner. Tell me about your dream trip and I\'ll create a personalized itinerary for you! 🗺️✈️',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(_tripService.createUserMessage(content));
      _isLoading = true;
    });

    // Add loading message
    setState(() {
      _messages.add(_tripService.createLoadingMessage());
    });

    try {
      ChatMessage response;
      
      // Check if this is a clarification response
      if (_pendingClarificationInput != null) {
        // Process clarification response
        response = await _tripService.processClarificationResponse(_pendingClarificationInput!, content);
        _pendingClarificationInput = null; // Clear pending clarification
      } else {
        // Process new user message
        response = await _tripService.processUserMessage(content);
        
        // Check if clarification is needed
        if (response.content.contains('I need a bit more information')) {
          _pendingClarificationInput = content; // Store original input for clarification
        }
      }
      
      setState(() {
        // Remove loading message
        _messages.removeWhere((msg) => msg.content.contains('Planning your perfect trip'));
        _messages.add(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Remove loading message
        _messages.removeWhere((msg) => msg.content.contains('Planning your perfect trip'));
        _messages.add(_tripService.createErrorMessage(e.toString()));
        _isLoading = false;
      });
    }
  }

  void _startStorytellingExperience(Itinerary itinerary) async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate storytelling experience
      final storytellingResponse = await _storytellingService.generateStorytellingExperience(itinerary);
      
      // Generate trip segments from storytelling response
      final tripSegments = _storytellingService.generateTripSegmentsFromStorytelling(storytellingResponse);
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorytellingScreen(
            tripSegments: tripSegments,
            storytellingResponse: storytellingResponse,
            itinerary: itinerary,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting storytelling experience: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveItinerary(Itinerary itinerary, {StorytellingResponse? storytellingResponse}) async {
    final tripId = '${itinerary.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _savingTrips[tripId] = true;
    });

    try {
      final title = _savedTripService.generateDefaultTitle(itinerary);
      final description = _savedTripService.generateDefaultDescription(itinerary);
      
      // Get cover image from first place if storytelling is available
      String? coverImageUrl;
      if (storytellingResponse?.days.isNotEmpty == true &&
          storytellingResponse!.days.first.places.isNotEmpty) {
        coverImageUrl = storytellingResponse.days.first.places.first.imageUrl;
      }

      await _savedTripService.saveTrip(
        title: title,
        description: description,
        itinerary: itinerary,
        storytellingResponse: storytellingResponse,
        coverImageUrl: coverImageUrl,
        tags: storytellingResponse != null 
            ? ['storytelling', 'visual', 'complete']
            : ['itinerary', 'basic'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storytellingResponse != null 
                ? 'Trip with visual story saved successfully!'
                : 'Itinerary saved successfully! You can generate visual storytelling later.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
          _savingTrips.remove(tripId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                
                if (message.itinerary != null) {
                  final tripId = '${message.itinerary.hashCode}_${index}';
                  final isSaving = _savingTrips[tripId] ?? false;
                  
                  return Column(
                    children: [
                      ChatBubble(message: message),
                      const SizedBox(height: 8),
                      ItinerarySummary(itinerary: message.itinerary!),
                      const SizedBox(height: 8),
                      
                      // Action buttons row
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            // Save Itinerary Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : () => _saveItinerary(message.itinerary!),
                                icon: isSaving 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.bookmark_add),
                                label: Text(isSaving ? 'Saving...' : 'Save Itinerary'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Storytelling Experience Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _startStorytellingExperience(message.itinerary!),
                                icon: const Icon(Icons.explore),
                                label: const Text('Visual Story'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...message.itinerary!.itinerary.map(
                        (dayPlan) => ItineraryCard(dayPlan: dayPlan),
                      ),
                    ],
                  );
                }
                
                return ChatBubble(message: message);
              },
            ),
          ),
          ChatInput(
            onSendMessage: _sendMessage,
            isLoading: _isLoading,
            isWaitingForClarification: _pendingClarificationInput != null,
          ),
        ],
      ),
    );
  }
}
