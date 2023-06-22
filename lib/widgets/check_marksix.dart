import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class Last60DaysWidget extends StatefulWidget {
  const Last60DaysWidget({Key? key}) : super(key: key);

  @override
  _Last60DaysWidgetState createState() => _Last60DaysWidgetState();
}

class _Last60DaysWidgetState extends State<Last60DaysWidget> {
  List<dynamic> _data = [];

  final _myBets = [
    [14, 16, 41, 44, 45, 46],
    [10, 11, 23, 35, 43, 47],
    [14, 29, 30, 32, 40, 42],
    [13, 16, 27, 32, 34, 43],
    [ 8, 15, 25, 27, 29, 48],
    [11, 15, 16, 18, 35, 45],
    [18, 19, 32, 45, 46, 49],
  ];
  
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final response = await http.get(Uri.parse('https://bet.hkjc.com/contentserver/jcbw/cmc/last60daysdraw.json'));
      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
          log(_data.toString());
        });
      } else {
        throw Exception(response.statusCode.toString());
      }
    } catch (e) {
      showErrorSnackBar('Failed to retrieve data' + e.toString().substring(0, 100) + "...");
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

  RichText checkMatching(String input, String special) {
    var r = <TextSpan>[];

    final numbers = input.split('+').map((e) => int.parse(e)).toList();
    final sno = int.tryParse(special);

    var s = "";
    for (var i in numbers) {
      s += sprintf("%d ", [i]);
    }
    r.add(TextSpan(text: sprintf("%s sno: %d\n\n", [s, sno])));

    for (var bet in _myBets) {
      var noMatch = 0.0;
      for (var i in bet) {
        final match = numbers.contains(i);
        noMatch += match ? 1 : 0;
        
        var style = const TextStyle();
        if (match) {
          style = const TextStyle(backgroundColor: Colors.green);
        } else if (i == sno) {
          style = const TextStyle(backgroundColor: Colors.yellow);
        }

        r.add(TextSpan(text: sprintf("%2d", [i]), 
          style: style));
        r.add(const TextSpan(text: " "));
      }
      if (bet.contains(sno)) {
        noMatch += 0.5;
      }
      var payout = 0;
      if (noMatch == 3) { payout = 40; }
      if (noMatch == 3.5) { payout = 320; }
      if (noMatch == 4) { payout = 640; }
      if (noMatch == 4.5) { payout = 9600; }

      r.add(TextSpan(text: sprintf(" - %.1f - %d\n", [noMatch, payout])));
    }

    return RichText(
      text: TextSpan(
        text: ' ',
        style: const TextStyle(color: Colors.black),
        children: r
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last 60 Days'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sprintf("%s - %s - 1st %s - %s", 
              [_data[index]["id"],
               _data[index]["date"],
               _data[index]["p1u"],
               _data[index]["sbnameC"],
               ])),
              checkMatching(_data[index]["no"], _data[index]["sno"]),
            ]
          );
        },
      ),
    );
  }
}

