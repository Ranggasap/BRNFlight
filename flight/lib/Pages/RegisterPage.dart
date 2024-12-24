import 'package:flight/Services/AuthService.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = "User";

  final AuthService _authService = AuthService();  // Instance AuthService

  // Fungsi untuk menangani registrasi
  void _handleRegister() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Memanggil fungsi register dari AuthService
      var user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        role: _selectedRole,
      );

      if (user != null) {
        // Menampilkan Snackbar jika registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi berhasil!')),
        );

        // Navigasi ke login page setelah berhasil
        Future.delayed(Duration(seconds: 1), () {
          _navigateToLoginPage(context);
        });
      } else {
        // Menampilkan Snackbar jika registrasi gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal registrasi, coba lagi!')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, coba lagi!')),
      );
    }
  }


  void _navigateToLoginPage(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "First Step\nLet's Make Your Own Account",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Image.network(
              'https://images.unsplash.com/photo-1603778863766-48c0ab66e9a1?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Ganti dengan URL gambar Anda
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ["Admin", "User"]
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Role',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Register',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Navigasi ke login page atau tambahkan logika lainnya
                _navigateToLoginPage(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Back to Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}