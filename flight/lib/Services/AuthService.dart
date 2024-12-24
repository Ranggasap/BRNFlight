import 'package:firebase_auth/firebase_auth.dart';
import 'FirestoreService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Fungsi untuk menambah pengguna baru
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      // Buat akun baru dengan Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Simpan data pengguna ke Firestore melalui FirestoreService
      if (user != null) {
        await _firestoreService.addUserToFirestore(
          uid: user.uid,
          email: email,
          username: username,
          role: role,
        );
      }

      return user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan pengguna yang sedang login
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Ambil data pengguna dari Firestore menggunakan FirestoreService
        return await _firestoreService.getUserData(user.uid);
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }

    return null;
  }

  // Fungsi untuk login menggunakan email dan password
  Future<User?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Login menggunakan Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Kembalikan data pengguna jika berhasil login
      return user;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }


  // Fungsi untuk logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
