import 'package:flutter/material.dart';
import 'package:gps_receiver/services.dart';
import 'dart:convert';

class ParamsPage extends StatefulWidget {
  const ParamsPage({super.key});

  @override
  _ParamsPageState createState() => _ParamsPageState();
}

class _ParamsPageState extends State<ParamsPage> {
  List<Map<String, dynamic>> _rovers = [];
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableRovers();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _fetchAvailableRovers() async {
    try {
      final response = await Services.getRequest('/rovers/available_rovers');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _rovers = data.map<Map<String, dynamic>>((rover) {
            return rover as Map<String, dynamic>;
          }).toList();
        });
      } else {
        print('Failed to load rovers: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load rovers: $e');
    }
  }

  void showParams(String roverId) async {
    try {
      final response = await Services.getRequest('/rovers/$roverId/params');
      if (response.statusCode == 200) {
        final Map<String, dynamic> params = jsonDecode(response.body);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            String searchQuery = '';
            Map<String, dynamic> filteredParams = params;

            return StatefulBuilder(
              builder: (context, setState) {
                void _filterParams(String query) {
                  searchQuery = query.toLowerCase();
                  setState(() {
                    filteredParams = Map<String, dynamic>.from(params);
                    filteredParams.removeWhere((key, value) =>
                        !key.toLowerCase().contains(searchQuery));
                  });
                }

                void _updateParam(
                    String key, dynamic newValue, List<String> keyPath) {
                  setState(() {
                    Map<String, dynamic> target = params;
                    for (int i = 0; i < keyPath.length - 1; i++) {
                      target = target[keyPath[i]] as Map<String, dynamic>;
                    }
                    target[keyPath.last]['value'] = newValue;
                  });
                }

                return AlertDialog(
                  title: Text('Parameters for Rover $roverId'),
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Search',
                            suffixIcon: Icon(Icons.search),
                          ),
                          onChanged: _filterParams,
                        ),
                        Expanded(
                          child: ListView(
                            children: _buildParamWidgets(
                                filteredParams, [], _updateParam),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Logic to send the updated parameters back to the server
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        print('Failed to load parameters: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load parameters: $e');
    }
  }

  List<Widget> _buildParamWidgets(
      Map<String, dynamic> params,
      List<String> keyPath,
      void Function(String, dynamic, List<String>) updateParam) {
    List<Widget> widgets = [];

    params.forEach((key, value) {
      final currentKeyPath = List<String>.from(keyPath)..add(key);

      if (value is Map<String, dynamic> && value.containsKey('value')) {
        widgets
            .add(_buildEditableField(key, value, currentKeyPath, updateParam));
      } else if (value is Map<String, dynamic>) {
        widgets.add(
          ExpansionTile(
            title: Text(key),
            children: _buildParamWidgets(value, currentKeyPath, updateParam),
          ),
        );
      } else {
        widgets.add(ListTile(title: Text('Unsupported type for $key')));
      }
    });

    return widgets;
  }

  Widget _buildEditableField(
      String key,
      Map<String, dynamic> value,
      List<String> keyPath,
      void Function(String, dynamic, List<String>) updateParam) {
    if (value['unit'] == 'bool') {
      return SwitchListTile(
        title: Text(value['description']),
        value: value['value'] == 1,
        onChanged: (bool newValue) {
          updateParam(key, newValue ? 1 : 0, keyPath);
        },
      );
    } else {
      return ListTile(
        title: Text(value['description']),
        subtitle: TextField(
          controller: TextEditingController(text: value['value'].toString()),
          keyboardType: _getKeyboardType(value['unit']),
          onChanged: (newValue) {
            updateParam(key, _parseValue(newValue, value['unit']), keyPath);
          },
        ),
      );
    }
  }

  TextInputType _getKeyboardType(String unit) {
    switch (unit) {
      case 'int':
      case 'float':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  dynamic _parseValue(String value, String unit) {
    switch (unit) {
      case 'int':
        return int.tryParse(value) ?? 0;
      case 'float':
        return double.tryParse(value) ?? 0.0;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Rovers',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _rovers.length,
              itemBuilder: (context, index) {
                final rover = _rovers[index];
                return ListTile(
                  title: Text(rover['rover_id']),
                  onTap: () {
                    showParams(rover['rover_id']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
