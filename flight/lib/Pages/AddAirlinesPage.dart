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

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Process form data
      String airlineName = _airlineNameController.text;
      String flightCode = _flightCodeController.text;
      String originCity = _originCityController.text;

      await _firestoreService.addAirlineToFirestore(
        airlineName: airlineName,
        flightCode: flightCode,
        originCity: originCity,
      );

      // Show a success message (you can replace this with actual form submission logic)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Airline added: $airlineName')),
      );

      // Optionally, you can clear the form after submission
      _airlineNameController.clear();
      _flightCodeController.clear();
      _originCityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Airline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Airline Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Airline Name Field
              TextFormField(
                controller: _airlineNameController,
                decoration: InputDecoration(
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
              SizedBox(height: 20),
              // Flight Code Field
              TextFormField(
                controller: _flightCodeController,
                decoration: InputDecoration(
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
              SizedBox(height: 20),
              // Origin City Field
              TextFormField(
                controller: _originCityController,
                decoration: InputDecoration(
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
              SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
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
