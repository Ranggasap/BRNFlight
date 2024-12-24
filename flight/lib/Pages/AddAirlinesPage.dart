import 'package:flight/Services/AuthService.dart';
import 'package:flight/Services/FirestoreService.dart';
import 'package:flutter/material.dart';

class AddAirlinesPage extends StatefulWidget {
  @override
  _AddAirlinesPageState createState() => _AddAirlinesPageState();
}

class _AddAirlinesPageState extends State<AddAirlinesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _airlineNameController = TextEditingController();
  final TextEditingController _flightCodeController = TextEditingController();
  final TextEditingController _originCityController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isAuthorized = true; // Default authorized

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      // Ambil data pengguna yang sedang login
      Map<String, dynamic>? currentUserData = await _authService.getCurrentUser();
      print(currentUserData);
      if (currentUserData == null || currentUserData['role'] != 'Admin') {
        setState(() {
          _isAuthorized = false;
        });
      }
    } catch (e) {
      print('Error checking user role: $e');
      setState(() {
        _isAuthorized = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      String airlineName = _airlineNameController.text;
      String flightCode = _flightCodeController.text;
      String originCity = _originCityController.text;

      await _firestoreService.addAirlineToFirestore(
        airlineName: airlineName,
        flightCode: flightCode,
        originCity: originCity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Airline added: $airlineName')),
      );

      Navigator.pushReplacementNamed(context, '/home');

      _airlineNameController.clear();
      _flightCodeController.clear();
      _originCityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      // Unauthorized UI
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unauthorized'),
        ),
        body: const Center(
          child: Text(
            'Unauthorized Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Authorized UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Airline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Airline Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Airline Name Field
              TextFormField(
                controller: _airlineNameController,
                decoration: const InputDecoration(
                  labelText: 'Airline Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.airplane_ticket),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the airline name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Flight Code Field
              TextFormField(
                controller: _flightCodeController,
                decoration: const InputDecoration(
                  labelText: 'Flight Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the flight code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Origin City Field
              TextFormField(
                controller: _originCityController,
                decoration: const InputDecoration(
                  labelText: 'Origin City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the origin city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Airline',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
