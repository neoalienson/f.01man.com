import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Last60DaysWidget extends StatefulWidget {
  const Last60DaysWidget({Key? key}) : super(key: key);

  @override
  _Last60DaysWidgetState createState() => _Last60DaysWidgetState();
}

class _Last60DaysWidgetState extends State<Last60DaysWidget> {
  List<dynamic> _data = [];
  
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final response = await http.get(Uri.parse('https://bet.hkjc.com/contentserver/jcbw/cmc/last60day'));
      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      showErrorSnackBar('Failed to retrieve data');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 48.0 * 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(message),
            ],
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Reload',
          textColor: Colors.white,
          onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar;
              getData();
          },
        ),        
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Last 60 Days'),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_data[index]['date']),
            subtitle: Text(_data[index]['result']),
          );
        },
      ),
    );
  }
}

