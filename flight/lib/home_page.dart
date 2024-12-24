import 'package:flutter/material.dart';
import 'flight_details_page.dart';
import 'AddJadwal.dart'; // Pastikan ini diimpor

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

  void _navigateToAddJadwal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirlineManagementPage(),
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
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
                    color: Colors.deepPurple[700],
                  ),
                ),
                subtitle: Text(
                  "Discover flights to ${flight['city']}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                onTap: () => _navigateToFlightDetails(context, flight["city"]!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddJadwal(context),
        label: Text("Tambah Jadwal"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
