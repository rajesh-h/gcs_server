import 'package:flutter/material.dart';
import 'services.dart';

class CombinedIpField extends StatefulWidget {
  final TextEditingController ipController;

  const CombinedIpField({super.key, required this.ipController});

  @override
  _CombinedIpFieldState createState() => _CombinedIpFieldState();
}

class _CombinedIpFieldState extends State<CombinedIpField> {
  List<String> _storedIPs = [];
  String? _selectedIP;

  @override
  void initState() {
    super.initState();
    _loadStoredIPs();
  }

  void _loadStoredIPs() async {
    List<String> ips = await Services.getStoredIPs();
    setState(() {
      _storedIPs = ips;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.ipController,
      decoration: InputDecoration(
        labelText: 'UDP Server IP Address',
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: () async {
            final selectedIp = await showModalBottomSheet<String>(
              context: context,
              builder: (BuildContext context) {
                return ListView(
                  children: _storedIPs.map((String ip) {
                    return ListTile(
                      title: Text(ip),
                      onTap: () {
                        Navigator.pop(context, ip);
                      },
                    );
                  }).toList(),
                );
              },
            );
            if (selectedIp != null) {
              setState(() {
                _selectedIP = selectedIp;
                widget.ipController.text = selectedIp;
              });
            }
          },
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _selectedIP = value;
        });
      },
    );
  }
}
