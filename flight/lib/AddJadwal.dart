import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AirlineManagementPage extends StatefulWidget {
  const AirlineManagementPage({Key? key}) : super(key: key);

  @override
  _AirlineManagementPageState createState() => _AirlineManagementPageState();
}

class _AirlineManagementPageState extends State<AirlineManagementPage> {
  final TextEditingController _airlineNameController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Tambahkan fungsi ini di class _AirlineManagementPageState
  String formatToRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAdmin = true;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _isAdmin = userDoc.get('isAdmin') ?? false;
      });
    }
  }

  Future<void> _saveFlight() async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unauthorized access')),
      );
      return;
    }

    if (_airlineNameController.text.isEmpty ||
        _flightNumberController.text.isEmpty ||
        _departureController.text.isEmpty ||
        _arrivalController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      String priceString = _priceController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .trim();
      double price = double.parse(priceString);

      await FirebaseFirestore.instance.collection('flights').add({
        'airlineName': _airlineNameController.text,
        'flightNumber': _flightNumberController.text,
        'departure': _departureController.text,
        'arrival': _arrivalController.text,
        'price': price,
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight schedule saved successfully')),
      );

      setState(() {
        _showForm = false;
      });
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving flight schedule: $e')),
      );
    }
  }

  Future<void> _deleteFlight(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('flights')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting flight: $e')),
      );
    }
  }

  void _clearFields() {
    _airlineNameController.clear();
    _flightNumberController.clear();
    _departureController.clear();
    _arrivalController.clear();
    _priceController.clear();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _navigateToEditPage(DocumentSnapshot flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlightPage(flight: flight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Unauthorized Access (Only Admin)',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4C53A5),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Airline Management",
          style: TextStyle(
            color: Color(0xFF4C53A5),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4C53A5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm;
          });
        },
        backgroundColor: Color(0xFF4C53A5),
        foregroundColor: Colors.white,
        child: Icon(_showForm ? Icons.close : Icons.add),
      ),
      body: Column(
        children: [
          if (_showForm)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      "Airline Name",
                      _airlineNameController,
                      Icons.flight,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      "Flight Number",
                      _flightNumberController,
                      Icons.numbers,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      "Departure City",
                      _departureController,
                      Icons.flight_takeoff,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      "Arrival City",
                      _arrivalController,
                      Icons.flight_land,
                    ),
                    _buildInputField(
                      "Price",
                      _priceController,
                      Icons.payments,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    _buildDateTimePicker(),
                    SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('flights')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No flights scheduled'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot flight = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          flight.data() as Map<String, dynamic>;
                      Timestamp timestamp = data['date'] as Timestamp;
                      DateTime date = timestamp.toDate();

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${data['airlineName']} - ${data['flightNumber']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${data['departure']} to ${data['arrival']}\n'
                            'Date: ${date.day}/${date.month}/${date.year}\n'
                            'Time: ${data['time']}\n'
                            'Price: ${formatToRupiah(data['price'])}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.edit, color: Color(0xFF4C53A5)),
                                onPressed: () => _navigateToEditPage(flight),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteFlight(flight.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            // Tambahkan kondisi untuk field price
            inputFormatters: label == "Price"
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    RupiahInputFormatter(),
                  ]
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Color(0xFF4C53A5)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C53A5),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.access_time, color: Colors.white),
            label: Text(
              '${_selectedTime.format(context)}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _selectTime,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C53A5),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveFlight,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Color(0xFF4C53A5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Flight Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// edit_flight_page.dart

class EditFlightPage extends StatefulWidget {
  final DocumentSnapshot flight;

  const EditFlightPage({Key? key, required this.flight}) : super(key: key);

  @override
  _EditFlightPageState createState() => _EditFlightPageState();
}

class _EditFlightPageState extends State<EditFlightPage> {
  final TextEditingController _airlineNameController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.flight.data() as Map<String, dynamic>;

    _airlineNameController.text = data['airlineName'];
    _flightNumberController.text = data['flightNumber'];
    _departureController.text = data['departure'];
    _arrivalController.text = data['arrival'];

    // Format price ke Rupiah
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    _priceController.text = formatter.format(data['price']);

    Timestamp timestamp = data['date'] as Timestamp;
    _selectedDate = timestamp.toDate();

    List<String> timeParts = data['time'].split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  @override
  void dispose() {
    _airlineNameController.dispose();
    _flightNumberController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateFlight() async {
    try {
      String priceString = _priceController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .trim();
      double price = double.parse(priceString);

      await FirebaseFirestore.instance
          .collection('flights')
          .doc(widget.flight.id)
          .update({
        'airlineName': _airlineNameController.text,
        'flightNumber': _flightNumberController.text,
        'departure': _departureController.text,
        'arrival': _arrivalController.text,
        'price': price,
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight schedule updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating flight schedule: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Edit Flight Schedule",
          style: TextStyle(
            color: Color(0xFF4C53A5),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4C53A5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              "Airline Name",
              _airlineNameController,
              Icons.flight,
            ),
            SizedBox(height: 20),
            _buildInputField(
              "Flight Number",
              _flightNumberController,
              Icons.numbers,
            ),
            SizedBox(height: 20),
            _buildInputField(
              "Departure City",
              _departureController,
              Icons.flight_takeoff,
            ),
            SizedBox(height: 20),
            _buildInputField(
              "Arrival City",
              _arrivalController,
              Icons.flight_land,
            ),
            _buildInputField(
              "Price",
              _priceController,
              Icons.payments,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _buildDateTimePicker(),
            SizedBox(height: 30),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            // Tambahkan kondisi untuk field price
            inputFormatters: label == "Price"
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    RupiahInputFormatter(),
                  ]
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Color(0xFF4C53A5)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C53A5),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.access_time, color: Colors.white),
            label: Text(
              '${_selectedTime.format(context)}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _selectTime,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C53A5),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateFlight,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Color(0xFF4C53A5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Update Flight Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
