import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTest {
  static Future<void> testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');
      
      // Test Firebase Core
      print('Firebase Core initialized: ${Firebase.apps.isNotEmpty}');
      
      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      print('Firebase Auth instance created: ${auth != null}');
      
      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      print('Firestore instance created: ${firestore != null}');
      
      // Test a simple Firestore operation
      await firestore.collection('test').doc('test').set({
        'test': 'value',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Firestore write test successful');
      
      // Clean up test document
      await firestore.collection('test').doc('test').delete();
      print('Firestore cleanup successful');
      
      print('All Firebase services are working correctly!');
    } catch (e) {
      print('Firebase test failed: $e');
      rethrow;
    }
  }
}
