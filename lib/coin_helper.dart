import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinHelper {
  static String get _currentUserKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'coins_$uid'; // 👈 每個使用者的 key 都不一樣
  }

  // 讀取目前金幣數
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentUserKey) ?? 100;
  }

  // 增加金幣
  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_currentUserKey) ?? 100;
    await prefs.setInt(_currentUserKey, current + amount);
  }

  // 減少金幣（不允許為負）
  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_currentUserKey) ?? 100;
    if (current >= amount) {
      await prefs.setInt(_currentUserKey, current - amount);
      return true;
    }
    return false;
  }

  // 重設金幣
  static Future<void> resetCoins([int initial = 100]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserKey, initial);
  }
}
