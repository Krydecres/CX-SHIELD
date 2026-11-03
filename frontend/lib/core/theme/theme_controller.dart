import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu lựa chọn giao diện sáng / tối / theo hệ thống trên thiết bị.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) : _mode = _parse(_prefs.getString(_key));

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static Future<ThemeController> load() async => ThemeController(await SharedPreferences.getInstance());

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }

  static ThemeMode _parse(String? value) =>
      ThemeMode.values.firstWhere((m) => m.name == value, orElse: () => ThemeMode.light);
}

/// Đưa [ThemeController] xuống cây widget để nút chọn giao diện dùng được ở mọi màn.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required ThemeController controller, required super.child})
      : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}
