import '../models/trip_request.dart';
import '../models/itinerary.dart';
import '../models/chat_message.dart';
import '../repository/trip_repository.dart';

class TripService {
  final TripRepository _repository = TripRepository();
  
  // Parse user input to extract trip requirements
  TripRequest parseUserInput(String userInput) {
    // Simple parsing logic for MVP
    // In production, this would use NLP/AI to extract structured data
    
    final input = userInput.toLowerCase();
    
    // Extract destination (simple keyword matching)
    String destination = 'Goa'; // Default
    if (input.contains('goa')) destination = 'Goa';
    else if (input.contains('mumbai')) destination = 'Mumbai';
    else if (input.contains('delhi')) destination = 'Delhi';
    else if (input.contains('bangalore')) destination = 'Bangalore';
    
    // Extract duration
    int duration = 5; // Default
    if (input.contains('3 day') || input.contains('3-day')) duration = 3;
    else if (input.contains('5 day') || input.contains('5-day')) duration = 5;
    else if (input.contains('7 day') || input.contains('7-day')) duration = 7;
    else if (input.contains('10 day') || input.contains('10-day')) duration = 10;
    
    // Extract budget
    double budget = 40000; // Default
    final budgetMatch = RegExp(r'(\d+)k').firstMatch(input);
    if (budgetMatch != null) {
      budget = double.parse(budgetMatch.group(1)!) * 1000;
    }
    
    // Extract interests
    List<String> interests = [];
    if (input.contains('food') || input.contains('foodie')) interests.add('food');
    if (input.contains('nightlife') || input.contains('party')) interests.add('nightlife');
    if (input.contains('adventure')) interests.add('adventure');
    if (input.contains('heritage') || input.contains('culture')) interests.add('heritage');
    if (input.contains('beach')) interests.add('beach');
    if (input.contains('shopping')) interests.add('shopping');
    
    return TripRequest(
      destination: destination,
      duration: duration,
      budget: budget,
      interests: interests,
    );
  }
  
  // Get itinerary - returns either clarification request OR itinerary
  Future<Map<String, dynamic>> getItinerary(String userInput) async {
    return await _repository.getItinerary(userInput);
  }

  // Get final itinerary - called only when clarification is needed
  Future<Itinerary> getFinalItinerary(String userInput, String clarificationAnswers) async {
    return await _repository.getFinalItinerary(userInput, clarificationAnswers);
  }

  // Legacy method for backward compatibility
  Future<Itinerary> generateItineraryFromRequest(TripRequest request) async {
    return await _repository.generateItineraryFromRequest(request);
  }
  
  // Create chat message from user input
  ChatMessage createUserMessage(String content) {
    return ChatMessage(
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }
  
  // Create assistant message with itinerary
  ChatMessage createAssistantMessage(String content, Itinerary? itinerary) {
    return ChatMessage(
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      itinerary: itinerary,
    );
  }
  
  // Process user message and check for clarification
  Future<ChatMessage> processUserMessage(String userInput) async {
    try {
      // Call get-itinerary API
      final response = await getItinerary(userInput);
      
      // Check if response contains clarification request
      if (response.containsKey('message') && response['message'] == 'Need clarification') {
        // Return clarification request message
        return createAssistantMessage(
          'I need a bit more information to plan your perfect trip! 🤔\n\n${response['resp']}',
          null,
        );
      } else if (response.containsKey('itinerary')) {
        // Response contains itinerary directly
        final itinerary = Itinerary.fromJson(response);
        return createAssistantMessage(
          'Here\'s your personalized ${itinerary.itinerary.length}-day itinerary! 🎉\n\nTotal estimated cost: ₹${itinerary.totalEstimatedCost.toStringAsFixed(0)}',
          itinerary,
        );
      } else {
        // Unexpected response format
        return createAssistantMessage(
          'Sorry, I received an unexpected response. Please try again. 😔',
          null,
        );
      }
    } catch (e) {
      print('Error processing user message: $e');
      return createAssistantMessage(
        'Sorry, I encountered an error while planning your trip. Please try again. 😔\n\nError: ${e.toString()}',
        null,
      );
    }
  }

  // Process clarification response and generate final itinerary
  Future<ChatMessage> processClarificationResponse(String originalInput, String clarificationAnswers) async {
    try {
      // Call get-final-itinerary API
      final itinerary = await getFinalItinerary(originalInput, clarificationAnswers);
      
      // Create response message
      return createAssistantMessage(
        'Perfect! Here\'s your personalized ${itinerary.itinerary.length}-day itinerary! 🎉\n\nTotal estimated cost: ₹${itinerary.totalEstimatedCost.toStringAsFixed(0)}',
        itinerary,
      );
    } catch (e) {
      print('Error processing clarification response: $e');
      return createAssistantMessage(
        'Sorry, I encountered an error while planning your trip. Please try again. 😔\n\nError: ${e.toString()}',
        null,
      );
    }
  }

  // Create loading message
  ChatMessage createLoadingMessage() {
    return createAssistantMessage(
      'Planning your perfect trip... ✈️\n\nThis may take a few moments while I research the best options for you.',
      null,
    );
  }

  // Create error message
  ChatMessage createErrorMessage(String error) {
    return createAssistantMessage(
      'Sorry, I encountered an error while planning your trip. Please try again. 😔\n\nError: $error',
      null,
    );
  }
}
