import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? get enrollment => _prefs?.getString('enrollment');
  static String? get role => _prefs?.getString('role');
  static String? get name => _prefs?.getString('name');
  static String? get career => _prefs?.getString('career');
  static String? get image => _prefs?.getString('image');

  static Future<void> setUserData({
    required String enrollment,
    required String role,
    required String name,
    required String career,
    required String image,


  }) async {
    await _prefs?.setString('enrollment', enrollment);
    await _prefs?.setString('role', role);
    await _prefs?.setString('name', name);
    await _prefs?.setString('career', career);
    await _prefs?.setString('image', image);


  }

  static Future<void> updatedProfileImage({
    required String image,
  }) async {
    await _prefs?.setString('image', image);
  }


  static Future<void> logout() async {
    await _prefs?.clear();
  }
}
