import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

  //provider 
  final tokenServiceProvider = Provider<TokenService>((ref){
    final prefs = ref.watch(sharedPreferencesProvider);
    return TokenService(prefs: prefs);
  });


class TokenService {
  final SharedPreferences _prefs;



  TokenService({required SharedPreferences prefs}) : _prefs = prefs;
  //save token
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  //get token
  String? getToken() {
    return _prefs.getString('auth_token');
  }

  //clear token
  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }
}