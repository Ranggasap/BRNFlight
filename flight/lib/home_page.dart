import 'package:flutter/material.dart';
import 'flight_details_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> flights = [
    {"city": "Jogja", "image": "assets/images/jogja.jpg"},
    {"city": "Surabaya", "image": "assets/images/surabaya.jpeg"},
    {"city": "Denpasar", "image": "assets/images/denpasar.jpeg"},
    {"city": "Pontianak", "image": "assets/images/pontianak.jpg"},
  ];

  void _navigateToFlightDetails(BuildContext context, String city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightDetailsPage(city: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BRN Flight", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) {
            final flight = flights[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 8,  // Add shadow for better visibility
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners for the card
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16), // Padding inside the tile
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                  child: Image.asset(
                    flight["image"]!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  flight["city"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple[700], // Title color
                  ),
                ),
                subtitle: Text(
                  "Discover flights to ${flight['city']}",
                  style: TextStyle(
                    color: Colors.grey[600], // Subtitle color
                    fontSize: 14,
                  ),
                ),
                onTap: () => _navigateToFlightDetails(context, flight["city"]!),
              ),
            );
          },
        ),
      ),
    );
  }
}
