import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SSEScreen(),
    );
  }
}

class SSEScreen extends StatefulWidget {
  @override
  _SSEScreenState createState() => _SSEScreenState();
}

class _SSEScreenState extends State<SSEScreen> {
  Map<String, dynamic> roverData = {};

  @override
  void initState() {
    super.initState();
    _listenToSSE();
  }

  void _listenToSSE() async {
    final client = http.Client();
    final request = http.Request(
        "GET",
        Uri.parse(
            "http://192.168.1.93:8222/sse/rovers/rov_1")); // Replace with your actual rover_id
    final response = await client.send(request);

    // Process the SSE stream
    response.stream
        .transform(Utf8Decoder())
        .transform(LineSplitter())
        .listen((line) {
      if (line.startsWith("data: ")) {
        setState(() {
          roverData = json.decode(line.substring(6)); // Update with new data
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rover Data"),
      ),
      body: roverData.isNotEmpty
          ? ListView(
              children: [
                ListTile(
                  title: Text("Rover ID: ${roverData['rover_id']}"),
                  subtitle: Text("Status: ${roverData['status']}"),
                ),
                // Add more UI elements based on the roverData
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
