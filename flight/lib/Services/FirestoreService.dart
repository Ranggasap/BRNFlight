import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk menambah data pengguna ke Firestore
  Future<void> addUserToFirestore({
    required String uid,
    required String email,
    required String username,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    }
    return null;
  }

  // Fungsi untuk menambahkan data maskapai penerbangan ke Firestore
  Future<void> addAirlineToFirestore({
    required String airlineName,
    required String flightCode,
    required String originCity,
  }) async {
    try {
      await _firestore.collection('airlines').add({
        'airline_name': airlineName,
        'flight_code': flightCode,
        'origin_city': originCity,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding airline to Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('purchase').get();
      return snapshot.docs.map((doc) {
        return {
          'date': doc['date'], // Timestamp
          'email': doc['email'], // String
          'id_flight': doc['id flight'], // String
          'price': doc['price'], // String
        };
      }).toList();
    } catch (e) {
      print('Error fetching purchases: $e');
      return [];
    }
  }
}
