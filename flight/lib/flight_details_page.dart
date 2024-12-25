import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlightDetailsPage extends StatefulWidget {
  final String city;

  FlightDetailsPage({required this.city});

  @override
  _FlightDetailsPageState createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
<<<<<<< Updated upstream
=======
  String? selectedFlightId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? departureCity;
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  // Format harga dengan format rupiah
  String formatCurrency(int price) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);
    return formatter.format(price);
  }

  Future<void> _bookFlight(Map<String, dynamic> flight) async {
    final dateTime = flight['date'].toDate();
=======
  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _bookFlight(Map<String, dynamic> flight) async {
    if (departureCity == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lengkapi semua informasi pemesanan.")),
      );
      return;
    }

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final dateFormatted = Timestamp.fromDate(dateTime);
>>>>>>> Stashed changes

    // Data untuk history
    final historyData = {
      "airlineName": flight['airlineName'],
      "arrivalCity": flight['arrival'],
      "createAt": FieldValue.serverTimestamp(),
<<<<<<< Updated upstream
      "date": flight['date'],
      "departureCity": flight['departure'],
=======
      "date": dateFormatted,
      "departureCity": departureCity,
>>>>>>> Stashed changes
      "email": currentUser?.email,
      "flightNumber": flight['flightNumber'],
      "price": flight['price'],
    };

    // Data untuk purchase
    final purchaseData = {
<<<<<<< Updated upstream
      "date": flight['date'],
      "email": currentUser?.email,
      "id flight": flight['flightNumber'],
=======
      "date": dateFormatted,
      "email": currentUser?.email,
      "idFlight": flight['flightNumber'],
>>>>>>> Stashed changes
      "price": flight['price'],
    };

    // Simpan ke Firestore
    await FirebaseFirestore.instance.collection('history').add(historyData);
    await FirebaseFirestore.instance.collection('purchase').add(purchaseData);

    Navigator.pop(context); // Kembali ke halaman sebelumnya

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tiket berhasil dipesan!")),
    );
  }

  Future<void> _showBookingDialog(Map<String, dynamic> flight) async {
    await showDialog(
      context: context,
      builder: (context) {
<<<<<<< Updated upstream
        final dateTime = flight['date'].toDate();
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
              Text("Date: ${DateFormat('dd MMM yyyy').format(dateTime)}"),
              Text("Time: ${DateFormat('HH:mm').format(dateTime)}"),
              // Format price ke dalam format rupiah
              Text("Price: ${formatCurrency(flight['price'])}"),
            ],
=======
        return AlertDialog(
          title: Text("Isi Detail Pemesanan"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Kota Keberangkatan"),
                  onChanged: (value) {
                    departureCity = value;
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? "Pilih Tanggal"
                              : "Tanggal: ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.edit_calendar, color: Colors.blue),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedTime == null
                              ? "Pilih Waktu"
                              : "Waktu: ${selectedTime!.format(context)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.edit, color: Colors.blue),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),


              ],
            ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
                      child: ListTile(
                        title: Text("${flight['airlineName']} - ${flight['flightNumber']}"),
                        subtitle: Text(
                            "Dari ${flight['departure']} ke ${flight['arrival']}"),
                        trailing: Text(formatCurrency(flight['price']),
                            style: TextStyle(color: Colors.green)),
>>>>>>> Stashed changes
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
