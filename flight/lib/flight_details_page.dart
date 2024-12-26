import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart' as intl;

class FlightDetailsPage extends StatefulWidget {
  final String city;

  FlightDetailsPage({required this.city});

  @override
  _FlightDetailsPageState createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  final Map<String, String> cityDescriptions = {
    "yogyakarta": "Jogja dikenal sebagai kota budaya dengan Candi Borobudur dan makanan khas Gudeg.",
    "surabaya": "Surabaya adalah kota pahlawan dengan wisata kuliner seperti Rawon dan Lontong Balap.",
    "denpasar": "Denpasar adalah jantung Bali dengan keindahan pantai dan makanan khas seperti Ayam Betutu.",
    "pontianak": "Pontianak terkenal dengan Tugu Khatulistiwa dan kuliner khas seperti Mie Tiaw.",
    "bandung": "Bandung memiliki udara sejuk, factory outlet, dan kuliner seperti Batagor dan Surabi."
  };

  final Map<String, List<String>> cityGalleryImages = {
    'bandung': [
      'assets/images/bandung.jpeg',
      'assets/images/bandung1.webp',
      'assets/images/bandung2.webp',
      'assets/images/bandung3.webp',
    ],
    'denpasar': [
      'assets/images/denpasar.jpeg',
      'assets/images/denpasar1.jpeg',
      'assets/images/denpasar2.jpeg',
      'assets/images/denpasar3.jpeg',
    ],
    'yogyakarta': [
      'assets/images/yogyakarta.jpg',
      'assets/images/yogyakarta1.jpg',
      'assets/images/yogyakarta2.jpg',
      'assets/images/yogyakarta3.jpg',
    ],
    'pontianak': [
      'assets/images/pontianak.jpg',
      'assets/images/pontianak1.jpg',
      'assets/images/pontianak2.jpg',
      'assets/images/pontianak3.jpg',
    ],
    'surabaya': [
      'assets/images/surabaya.jpeg',
      'assets/images/surabaya1.jpeg',
      'assets/images/surabaya2.jpg',
      'assets/images/surabaya3.jpg',
    ],
  };

  String formatCurrency(int price) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);
    return formatter.format(price);
  }

  String formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String formatTime(String time) {
    // Memisahkan jam dan menit
    final timeParts = time.split(":");
    String hour = timeParts[0];
    String minute = timeParts.length > 1 ? timeParts[1] : "00"; // Jika menit tidak ada, anggap "00"
    
    // Menambahkan leading zero jika jam atau menit hanya memiliki 1 digit
    hour = hour.padLeft(2, '0');
    minute = minute.padLeft(2, '0');

    return "$hour:$minute"; // Mengembalikan dalam format HH:mm
  }

  Future<void> _bookFlight(Map<String, dynamic> flight) async {
    final historyData = {
      "airlineName": flight['airlineName'],
      "arrivalCity": flight['arrival'],
      "createAt": FieldValue.serverTimestamp(),
      "date": flight['date'],
      "departureCity": flight['departure'],
      "email": currentUser?.email,
      "flightNumber": flight['flightNumber'],
      "price": flight['price'],
      "time": flight['time'],  // Simpan time sebagai string
    };

    final purchaseData = {
      "date": flight['date'],
      "email": currentUser?.email,
      "id flight": flight['flightNumber'],
      "price": flight['price'],
      "time": flight['time'],  // Simpan time sebagai string
    };

    await FirebaseFirestore.instance.collection('history').add(historyData);
    await FirebaseFirestore.instance.collection('purchase').add(purchaseData);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tiket berhasil dipesan!")),
    );
  }

  Future<void> _showBookingDialog(Map<String, dynamic> flight) async {
    await showDialog(
      context: context,
      builder: (context) {
        final dateTime = flight['date'] as Timestamp;
        final time = flight['time'] ?? "Waktu tidak tersedia";  // Gunakan waktu dari Firestore
        final formattedTime = formatTime(time);  // Format waktu dengan leading zero
        return AlertDialog(
          title: Text("Detail Pemesanan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Airline: ${flight['airlineName']}"),
              Text("Flight Number: ${flight['flightNumber']}"),
              Text("Departure: ${flight['departure']}"),
              Text("Arrival: ${flight['arrival']}"),
              Text("Date: ${formatDateTime(dateTime)}"),
              Text("Time: $formattedTime"),  // Menampilkan waktu yang sudah diformat
              Text("Price: ${formatCurrency(flight['price'])}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookFlight(flight);
              },
              child: Text("Booking Sekarang"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city.toLowerCase();
    final description = cityDescriptions[city] ?? "Informasi wisata tidak tersedia.";
    final galleryImages = cityGalleryImages[city] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Flight to ${widget.city}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore ${widget.city}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Gallery",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: galleryImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.asset(galleryImages[index], fit: BoxFit.cover),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        galleryImages[index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Available Flights",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('flights')
                  .where('arrival', isEqualTo: widget.city)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("Tidak ada penerbangan tersedia.");
                }

                final flights = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: flights.length,
                  itemBuilder: (context, index) {
                    final flight = flights[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.flight_takeoff, color: Colors.blue),
                        title: Text(
                          "${flight['airlineName']} - ${flight['flightNumber']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Dari ${flight['departure']} ke ${flight['arrival']}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                        onTap: () {
                          _showBookingDialog(flight);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
