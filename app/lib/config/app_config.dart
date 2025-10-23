import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleMapsApiKey {
    // In production, this should come from environment variables
    // For now, we'll use a placeholder that you need to replace
    return dotenv.env['GOOGLE_MAPS_API_KEY']!;
  }

  static String get backendApiUrl {
    return dotenv.env['BACKEND_API_URL'] ??
        'https://trip-planner-genai-production.up.railway.ap';
  }

  static String get openaiApiKey {
    return dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  static String get razorpayKeyId {
    return dotenv.env['RAZORPAY_KEY_ID'] ?? '';
  }

  static String get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  }

  // Development vs Production
  static bool get isDevelopment {
    return dotenv.env['ENVIRONMENT'] == 'development';
  }

  static bool get isProduction {
    return dotenv.env['ENVIRONMENT'] == 'production';
  }
}
