import 'package:shared_preferences/shared_preferences.dart';

class CoinHelper {
  static const String _coinKey = 'coins';

  // 讀取目前金幣數
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 100;
  }

  // 增加金幣
  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinKey) ?? 100;
    await prefs.setInt(_coinKey, current + amount);
  }

  // 減少金幣（不允許為負，失敗會回傳 false）
  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinKey) ?? 100;
    if (current >= amount) {
      await prefs.setInt(_coinKey, current - amount);
      return true;
    }
    return false;
  }

  // 重設金幣（可傳入初始值）
  static Future<void> resetCoins([int initial = 100]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinKey, initial);
  }
}
