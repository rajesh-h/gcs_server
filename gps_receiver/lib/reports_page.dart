import 'package:flutter/material.dart';
import 'package:gps_receiver/services.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<String> _udpData = [];
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _initializeUDP();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _initializeUDP() async {
    await Services.receiveUDP(5006); // Start UDP listener on port 12345
    Services.udpStream.listen((data) {
      if (_isMounted) {
        setState(() {
          _udpData.add(data);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UDP Data',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _udpData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_udpData[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
