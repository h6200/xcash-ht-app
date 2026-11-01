import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String BASE_URL = 'https://jaxqmsyiciqreudspcpt.supabase.co/functions/v1/xcash';
  static String? token;
  static String? phone;

  static Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('token');
    phone = p.getString('phone');
  }

  static Future<void> saveSession(String? t, String? p) async {
    token = t;
    phone = p;
    final prefs = await SharedPreferences.getInstance();
    if (t != null) {
      await prefs.setString('token', t);
    } else {
      await prefs.remove('token');
    }
    if (p != null) {
      await prefs.setString('phone', p);
    } else {
      await prefs.remove('phone');
    }
  }

  static Map<String, String> _headers([bool auth = true]) {
    final h = {'Content-Type': 'application/json'};
    if (auth && token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Future<Map<String, dynamic>> _parse(http.Response r) async {
    try {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {'ok': false, 'error': 'Repons pa valid (${r.statusCode})'};
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, [bool auth = true]) async {
    try {
      final r = await http.post(Uri.parse('$BASE_URL$path'), headers: _headers(auth), body: jsonEncode(body));
      return _parse(r);
    } catch (e) {
      return {'ok': false, 'error': 'Pa ka konekte ak serve a'};
    }
  }

  static Future<Map<String, dynamic>> get(String path, [bool auth = true]) async {
    try {
      final r = await http.get(Uri.parse('$BASE_URL$path'), headers: _headers(auth));
      return _parse(r);
    } catch (e) {
      return {'ok': false, 'error': 'Pa ka konekte ak serve a'};
    }
  }
}
