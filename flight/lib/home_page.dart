import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight/HistoryPage.dart';
import 'package:flight/Pages/AddAirlinesPage.dart';
import 'package:flight/Pages/DashboardAdminPage.dart';
import 'package:flight/Pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'AddJadwal.dart';
import 'flight_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String email = '';
  String role = '';
  String searchQuery = '';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? '';
      });
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            role = querySnapshot.docs.first['role'];
            isAdmin = role == 'Admin';
          });
        }
      });
    }
  }

  void _navigateToFlightDetails(BuildContext context, String arrival) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightDetailsPage(city: arrival),
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

  void _navigateToAddAirlinesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAirlinesPage(),
      ),
    );
  }

  void _navigateToDashboardAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardAdminPage(),
      ),
    );
  }

  void _navigateToHistoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(),
      ),
    );
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  String _getImageForArrival(String arrival) {
    switch (arrival.toLowerCase()) {
      case 'bandung':
        return 'assets/images/bandung.jpeg';
      case 'yogyakarta':
        return 'assets/images/yogyakarta.jpg';
      case 'denpasar':
        return 'assets/images/denpasar.jpeg';
      case 'pontianak':
        return 'assets/images/pontianak.jpg';
      case 'surabaya':
        return 'assets/images/surabaya.jpeg';
      default:
        return 'assets/images/default.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BRN Flight", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 246, 246, 246),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _navigateToHistoryPage(context),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search city',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            if (isAdmin)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToAddJadwal(context),
                    child: Text("Tambah Jadwal\nPenerbangan", textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToDashboardAdmin(context),
                    child: Text("Dashboard", textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToAddAirlinesPage(context),
                    child: Text("Tambah\nAirline", textAlign: TextAlign.center),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('flights').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No flights available'));
                  }

                  final flights = snapshot.data!.docs;
                  final uniqueArrivals = <String, QueryDocumentSnapshot>{};

                  for (var flight in flights) {
                    final arrival = flight['arrival'] as String;
                    if (!uniqueArrivals.containsKey(arrival.toLowerCase())) {
                      uniqueArrivals[arrival.toLowerCase()] = flight;
                    }
                  }

                  return ListView(
                    children: uniqueArrivals.values.map((doc) {
                      final arrival = doc['arrival'] as String;
                      final imagePath = _getImageForArrival(arrival);

                      if (searchQuery.isNotEmpty &&
                          !arrival.toLowerCase().contains(searchQuery.toLowerCase())) {
                        return Container();
                      }

                      return GestureDetector(
                        onTap: () => _navigateToFlightDetails(context, arrival),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  imagePath,
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.flight_takeoff, color: Colors.white),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          arrival,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
