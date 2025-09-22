import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('Starting sign up process...');
      
      // Create user with Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('User created successfully: ${result.user?.uid}');
      
      final user = result.user;
      if (user != null) {
        // Update display name if provided
        if (displayName != null) {
          await user.updateDisplayName(displayName);
          print('Display name updated: $displayName');
        }

        // Create user document in Firestore
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: {
            'interests': [],
            'budget_range': 'medium',
            'travel_style': 'balanced',
          },
          savedTrips: [],
        );

        print('Creating user document in Firestore...');
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
        
        print('User document created successfully');
        return userModel;
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });

        // Get user data from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final User? user = currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }
    return null;
  }

  // Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final User? user = currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'preferences': preferences,
        });
      } catch (e) {
        throw Exception('Failed to update preferences: $e');
      }
    }
  }

  // Add trip to saved trips
  Future<void> addSavedTrip(String tripId) async {
    final User? user = currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'savedTrips': FieldValue.arrayUnion([tripId]),
        });
      } catch (e) {
        throw Exception('Failed to save trip: $e');
      }
    }
  }

  // Remove trip from saved trips
  Future<void> removeSavedTrip(String tripId) async {
    final User? user = currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'savedTrips': FieldValue.arrayRemove([tripId]),
        });
      } catch (e) {
        throw Exception('Failed to remove trip: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final User? user = currentUser;
    if (user != null) {
      try {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
    }
  }
}
