import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gps_receiver/sample_data.dart';
import 'package:gps_receiver/user_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  static const String ipKey = 'server_ip';
  static const String isLoggedInKey = 'isLoggedIn';
  static final StreamController<String> _udpStreamController =
      StreamController.broadcast();

  static Stream<String> get udpStream => _udpStreamController.stream;

  static Future<void> receiveUDP(int port) async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = udpSocket.receive();
          if (datagram != null) {
            String message = utf8.decode(datagram.data);
            _udpStreamController.add(message);
          }
        }
      });
    });
  }

  static Future<List<String>> getStoredIPs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(ipKey) ?? [];
  }

  static Future<void> saveIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ips = prefs.getStringList(ipKey) ?? [];
    if (!ips.contains(ip)) {
      ips.add(ip);
      prefs.setStringList(ipKey, ips);
    }
  }

  static bool isUsernameAndPasswordValid(String username, String password) {
    return UserConfig.users.any(
        (user) => user['username'] == username && user['password'] == password);
  }

  static Future<void> registerWithServer(
      String serverIp, String username, String password) async {
    if (!isUsernameAndPasswordValid(username, password)) {
      throw Exception('Invalid username or password');
    }
    await saveIP(serverIp);
    sendUDP('register', serverIp, 5005);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isRegistered', true);
    });
  }

  static Future<void> login(
      String serverIp, String username, String password) async {
    if (!isUsernameAndPasswordValid(username, password)) {
      throw Exception('Invalid username or password');
    }
    await saveIP(serverIp);
    sendUDP('register', serverIp, 5005);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
  }

  static Future<void> setUserLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isLoggedInKey);
  }

  static Future<bool> isUserAlreadyLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(isLoggedInKey) ?? false;
    return isLoggedIn;
  }

  static Future<http.Response> getRequest(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverIp = prefs.getString(ipKey);

    final url = Uri.http(serverIp!, endpoint);
    final response = await http.get(url);
    return response;
  }

  static Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverIp = prefs.getString(ipKey);

    final url = Uri.http(serverIp!, endpoint);
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    return response;
  }

  // static Future<void> receiveUDP(
  //     int port, Function(String) onDataReceived) async {
  //   RawDatagramSocket.bind(InternetAddress.anyIPv4, port)
  //       .then((RawDatagramSocket udpSocket) {
  //     udpSocket.listen((RawSocketEvent event) {
  //       if (event == RawSocketEvent.read) {
  //         Datagram? datagram = udpSocket.receive();
  //         if (datagram != null) {
  //           String message = utf8.decode(datagram.data);
  //           onDataReceived(message);
  //         }
  //       }
  //     });
  //   });
  // }

  static Future<void> sendUDP(String message, String address, int port) async {
    print('inside sendudp');
    final udpSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5006);
    udpSocket.send(utf8.encode(message), InternetAddress(address), 5005);
    udpSocket.close();
  }

  Future<List<Map<String, dynamic>>> getActiveAGVs() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return availableAGVs;
  }

  Future<List<Map<String, dynamic>>> getActiveProjects() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return activeProjects;
  }
}
