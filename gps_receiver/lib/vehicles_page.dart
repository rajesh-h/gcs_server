import 'package:flutter/material.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),
      body: const Center(
        child: Text(
          'Vehicles Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
