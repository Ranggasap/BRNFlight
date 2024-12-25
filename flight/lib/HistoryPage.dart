import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Mengimpor package intl untuk format mata uang

class HistoryPage extends StatelessWidget {
  // Fungsi untuk format harga menjadi Rupiah
  String formatCurrency(int price) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);
    return formatter.format(price);
  }

  // Fungsi untuk format tanggal dan waktu
  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: user == null
          ? Center(child: Text('No user logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('history')
                  .where('email', isEqualTo: user.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No history found'));
                }

                final historyDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final doc = historyDocs[index];
                    final airlineName = doc['airlineName'] ?? 'No airline name';
                    final arrivalCity = doc['arrivalCity'] ?? 'No arrival city';
                    final departureCity = doc['departureCity'] ?? 'No departure city';
                    final flightNumber = doc['flightNumber'] ?? 'No flight number';
                    final price = doc['price'] ?? 0;
                    final email = doc['email'] ?? 'No email';
                    final createAt = (doc['createAt'] as Timestamp?)?.toDate();
                    final date = (doc['date'] as Timestamp?)?.toDate();

                    // Jika createAt dan date tidak null, format tanggal dan waktu dengan benar
                    final formattedCreateAt = createAt != null
                        ? formatDateTime(createAt.toLocal())  // Mengonversi ke waktu lokal
                        : 'No date';
                    final formattedDate = date != null
                        ? formatDateTime(date.toLocal())  // Mengonversi ke waktu lokal
                        : 'No date';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(airlineName, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Flight Number: $flightNumber'),
                            Text('Arrival City: $arrivalCity'),
                            Text('Departure City: $departureCity'),
                            // Format harga menjadi Rupiah
                            Text('Price: ${formatCurrency(price)}'),
                            Text('Date: $formattedDate'),
                            Text('Created At: $formattedCreateAt'),
                          ],
                        ),
                        leading: Icon(Icons.flight, size: 40),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
