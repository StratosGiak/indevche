import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rodis_service/models/record.dart';

class ApiHandler {
  static const apiUrl = "http://188.245.190.233/api";
  static const photoUrl = "http://188.245.190.233/media/images";
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<http.Response> _get(Uri uri) async {
    return http.get(uri, headers: headers);
  }

  Future<http.Response> _post(Uri uri, {Object? body}) async {
    final response = await http.post(uri, headers: headers, body: body);
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers.addAll({
        'cookie': (index == -1) ? rawCookie : rawCookie.substring(0, index),
      });
    }
    return response;
  }

  Future<http.Response> _put(Uri uri, {Object? body}) async {
    return http.put(uri, headers: headers, body: body);
  }

  Future<Map<String, dynamic>> getSuggestions() async {
    final response = await _get(Uri.parse("$apiUrl/suggestions"));
    final json = (jsonDecode(response.body) as Map<String, dynamic>)
        .cast<String, List<dynamic>>();
    return json.map(
      (key, value) => MapEntry(
        key,
        {for (var item in value) item['id'] as int: item['onoma'] as String},
      ),
    );
  }

  Future<List<Record>> getRecordsBy(int id) async {
    final response = await _get(Uri.parse("$apiUrl/records/by/$id"));
    final json =
        (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    return json.map((element) => Record.fromJSON(element)).toList();
  }

  Future<Map<String, dynamic>?> postLogin(
    String username,
    String password,
  ) async {
    final response = await _post(
      Uri.parse("$apiUrl/login"),
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode != 200) return null;

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> postRecord(Map<String, Object?> record) async {
    final response =
        await _post(Uri.parse("$apiUrl/records/new"), body: jsonEncode(record));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> putRecord(Map<String, Object?> record) async {
    final response = await _put(
      Uri.parse("$apiUrl/records/${record['id']}/edit"),
      body: jsonEncode(record),
    );
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body);
  }

  Future<String?> postPhoto(String path) async {
    final request = http.MultipartRequest('POST', Uri.parse("$apiUrl/media"))
      ..headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath('file', path),
    );
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) return null;
    return response.body;
  }
}