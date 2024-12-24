import 'package:flutter/material.dart';

class FlightDetailsPage extends StatelessWidget {
  final String city;

  FlightDetailsPage({required this.city});

  final Map<String, String> cityDescriptions = {
    "Jogja": "Jogja terkenal dengan keindahan budaya dan wisata kuliner seperti Gudeg dan Sate Klathak.",
    "Surabaya": "Surabaya adalah kota pahlawan dengan tempat wisata kuliner seperti Rawon dan Lontong Balap.",
    "Denpasar": "Denpasar adalah pusat Bali, terkenal dengan pantai dan kuliner khas seperti Babi Guling.",
    "Pontianak": "Pontianak terkenal dengan kuliner khas seperti Mie Tiaw dan Tahu Tek.",
  };

  final List<Map<String, String>> flightSchedule = [
    {
      "airline": "Nico Airline",
      "flightNumber": "1515",
      "departureCity": "Jakarta",
      "arrivalCity": "Denpasar",
      "price": "Rp 1.500.000",
      "date": "25 Desember 2024",
      "time": "10:00 AM - 01:00 PM"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final description = cityDescriptions[city] ?? "Informasi wisata tidak tersedia.";

    return Scaffold(
      appBar: AppBar(
        title: Text("Flight to $city"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore $city",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              "Available Flights",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: flightSchedule.length,
              itemBuilder: (context, index) {
                final flight = flightSchedule[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text("${flight['airline']} - ${flight['flightNumber']}"),
                    subtitle: Text(
                        "From ${flight['departureCity']} to ${flight['arrivalCity']}"),
                    trailing: Text(flight['price']!, style: TextStyle(color: Colors.green)),
                    onTap: () {
                      // Bisa tambahkan logic untuk booking di sini
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Selected flight to $city!")),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
