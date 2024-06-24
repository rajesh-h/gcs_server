import 'dart:convert';
import 'dart:io';
import 'package:gps_receiver/user_config.dart';

class UdpHandler {
  RawDatagramSocket? _udpSocket;

  Future<void> registerWithServer(
      String serverIp,
      String username,
      String password,
      Function onRegisterSuccess,
      Function(String) onRegisterFailure) async {
    if (serverIp.isEmpty || username.isEmpty || password.isEmpty) {
      onRegisterFailure('Server IP, Username or Password cannot be empty');
      return;
    }

    // Validate username and password
    bool isValidUser = UserConfig.users.any(
        (user) => user['username'] == username && user['password'] == password);

    if (!isValidUser) {
      onRegisterFailure('Invalid username or password');
      return;
    }

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 5006)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.send(utf8.encode('register'), InternetAddress(serverIp), 5005);
      udpSocket.close();
      onRegisterSuccess();
    });
  }

  void startUdpListener(Function(String) onDataReceived) async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 5006)
        .then((RawDatagramSocket udpSocket) {
      _udpSocket = udpSocket;
      udpSocket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = udpSocket.receive();
          if (datagram != null) {
            String message = utf8.decode(datagram.data);
            onDataReceived(message);
          }
        }
      });
    });
  }

  void dispose() {
    _udpSocket?.close();
  }
}
