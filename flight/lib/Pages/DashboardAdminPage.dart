import 'package:flight/Services/AuthService.dart';
import 'package:flight/Services/FirestoreService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import Firestore package

class DashboardAdminPage extends StatefulWidget {
  @override
  _DashboardAdminPageState createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final FirestoreService firestoreService = FirestoreService();
  final AuthService authService = AuthService();

  bool _isAuthorized = true; // Default to true, will change if not authorized

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Check user role and authorize access to the page
  Future<void> _checkUserRole() async {
    try {
      // Get current user data
      Map<String, dynamic>? currentUserData = await authService.getCurrentUser();
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

  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    try {
      return await firestoreService.getAllPurchases();
    } catch (e) {
      print('Error fetching purchases: $e');
      return [];
    }
  }

  int getTotalTicketsSold(List<Map<String, dynamic>> ticketData) {
    return ticketData.length;
  }

  double getTotalEarning(List<Map<String, dynamic>> ticketData) {
    return ticketData.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
  }

  double getMostExpensiveTicket(List<Map<String, dynamic>> ticketData) {
    return ticketData.map((item) => item['price'] ?? 0.0).reduce((a, b) => a > b ? a : b);
  }

  double getMostCheapTicket(List<Map<String, dynamic>> ticketData) {
    return ticketData.map((item) => item['price'] ?? 0.0).reduce((a, b) => a < b ? a : b);
  }

  // Function to convert Firestore Timestamp to formatted DateTime string
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  // Function to format numbers as currency (Rupiah)
  String formatCurrency(double value) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp',    // Currency symbol
      decimalDigits: 0, // No decimal places
    );
    return currencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      // Unauthorized UI
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unauthorized'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Unauthorized Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home'); // Redirect to Home
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final ticketData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ticket Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Tabel
                Expanded(
                  child: ListView(
                    children: [
                      Table(
                        border: TableBorder.all(color: Colors.black),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          // Header
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Ticket Price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Purchased Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Rows
                          ...ticketData.map(
                                (item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item['email']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(formatCurrency(item['price'] ?? 0.0)), // Format price as currency
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(formatDate(item['date'])), // Format the Timestamp
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Summary Text
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow('Total Ticket Sold', '${getTotalTicketsSold(ticketData)} tickets'),
                _buildSummaryRow('Total Earning', formatCurrency(getTotalEarning(ticketData))),
                _buildSummaryRow('Most Expensive Ticket', formatCurrency(getMostExpensiveTicket(ticketData))),
                _buildSummaryRow('Most Cheap Ticket', formatCurrency(getMostCheapTicket(ticketData))),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget untuk summary row
  Widget _buildSummaryRow(String title, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            result,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
