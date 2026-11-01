import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String BASE_URL =
    "https://jaxqmsyiciqreudspcpt.supabase.co/functions/v1/xcash";

class Api {
  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<void> saveToken(String t) async {
    _token = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', t);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static String? get token => _token;

  static Map<String, String> _headers({bool auth = true}) {
    final h = {'Content-Type': 'application/json'};
    if (auth && _token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? adminPin,
  }) async {
    final uri = Uri.parse('$BASE_URL$path');
    final headers = _headers(auth: auth);
    if (adminPin != null) headers['x-admin-pin'] = adminPin;

    http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers);
          break;
        case 'POST':
          res = await http.post(uri,
              headers: headers, body: jsonEncode(body ?? {}));
          break;
        default:
          res = await http.get(uri, headers: headers);
      }
    } catch (e) {
      throw ApiException('Pa ka konekte ak sèvè a. Tcheke entènèt ou.');
    }

    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) {
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Erè sèvè (${res.statusCode})';
      throw ApiException(msg);
    }
    return data is Map<String, dynamic> ? data : {'data': data};
  }

  // Auth
  static Future<Map<String, dynamic>> register(
      String phone, String first, String last) async {
    return _request('POST', '/auth/register',
        body: {'phone': phone, 'first_name': first, 'last_name': last},
        auth: false);
  }

  static Future<Map<String, dynamic>> login(String phone) async {
    return _request('POST', '/auth/login',
        body: {'phone': phone}, auth: false);
  }

  // Core
  static Future<List<dynamic>> plans() async {
    final r = await _request('GET', '/plans', auth: false);
    return r['plans'] ?? [];
  }

  static Future<Map<String, dynamic>> me() async {
    final r = await _request('GET', '/me');
    return r['user'] ?? {};
  }

  static Future<Map<String, dynamic>> invest(String planId) async {
    return _request('POST', '/invest', body: {'plan_id': planId});
  }

  static Future<List<dynamic>> myInvestments() async {
    final r = await _request('GET', '/investments/mine');
    return r['investments'] ?? [];
  }

  static Future<Map<String, dynamic>> depositCreate(
      int amount, String provider) async {
    return _request('POST', '/deposit/create',
        body: {'amount': amount, 'provider': provider});
  }

  static Future<Map<String, dynamic>> withdrawCreate(
      int amount, String targetPhone, {String provider = 'moncash'}) async {
    return _request('POST', '/withdraw/create',
        body: {
          'amount': amount,
          'target_phone': targetPhone,
          'provider': provider
        });
  }

  static Future<List<dynamic>> myWithdrawals() async {
    final r = await _request('GET', '/withdrawals/mine');
    return r['withdrawals'] ?? [];
  }

  static Future<List<dynamic>> myDeposits() async {
    final r = await _request('GET', '/deposits/mine');
    return r['deposits'] ?? [];
  }

  static Future<List<dynamic>> myTransactions() async {
    final r = await _request('GET', '/transactions/mine');
    return r['transactions'] ?? [];
  }

  // Admin
  static Future<Map<String, dynamic>> adminDashboard(String pin) async {
    return _request('GET', '/admin/dashboard', adminPin: pin);
  }

  static Future<List<dynamic>> adminUsers(String pin) async {
    final r = await _request('GET', '/admin/users', adminPin: pin);
    return r['users'] ?? [];
  }

  static Future<List<dynamic>> adminWithdrawals(String pin) async {
    final r = await _request('GET', '/admin/withdrawals', adminPin: pin);
    return r['withdrawals'] ?? [];
  }

  static Future<List<dynamic>> adminDeposits(String pin) async {
    final r = await _request('GET', '/admin/deposits', adminPin: pin);
    return r['deposits'] ?? [];
  }

  static Future<Map<String, dynamic>> adminAdjustBalance(
      String pin, String userId, double amount, String action, String note) async {
    return _request('POST', '/admin/user/balance',
        adminPin: pin,
        body: {
          'user_id': userId,
          'amount': amount,
          'action': action,
          'note': note,
        });
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
