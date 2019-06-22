import 'package:http/http.dart' as http;
import 'dart:convert';

//final String url = 'http://0fee0827.ngrok.io/report';

final String url = 'https://azuka.dev/report';

Future sendData(String title, String description, String category, double latitude, double longitude) async{

  final Map<String, dynamic> reportData = {
    'title': title,
    'description': description,
    'category' : category,
    'latitude': latitude,
    'longitude': longitude
  };
  print(url);
  print(json.encode(reportData));
  var response = await http.post(url,  headers: {"Content-Type": "application/json"}, body: json.encode(reportData));

  print(response.body);

  String message = response.body;

  return message;
}