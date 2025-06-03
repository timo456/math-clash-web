import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_clash/shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'character_select_page.dart';
import 'coin_helper.dart';
import 'difficulty_page.dart';
import 'game_page.dart';
import 'guide_page.dart';
import 'leaderboard_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 0;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coin = await CoinHelper.getCoins(); // ⬅️ 使用 CoinHelper
    setState(() {
      coins = coin;
    });
  }


  Future<void> _playClickSound() async {
    final prefs = await SharedPreferences.getInstance();
    double volume = prefs.getDouble('volume') ?? 0.5;

    await _sfxPlayer.play(
      AssetSource('sounds/click.mp3'),
      volume: volume,
    );
  }


  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      shadowColor: Colors.purpleAccent,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF), // Q版紫粉底色
      body: Stack(
        children: [
          // 背景圖可改為雲朵、漸層等
          Positioned.fill(
            child: Image.asset(
              'bg_main.png', // 選用 Q 版背景圖（或可移除這行保留純色）
              fit: BoxFit.cover,
            ),
          ),

          // 頭像 or 裝飾
          Positioned(top: 50, right: 20, child: Icon(Icons.account_circle, size: 50, color: Colors.grey[400])),

          // 中心主體內容
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Stack(
              children: [
              // 底層：描邊效果（粗字、白色）
              Text(
              '🌟 MATH CLASH 🌟',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = Colors.white, // 👈 邊框顏色
                ),
              ),
              // 上層：內部實心字
              Text(
                '🌟 MATH CLASH 🌟',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.deepPurple[800], // 👈 內部填色
                ),
              ),
              ],
            ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Text(
                      '💰 金幣：$coins',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ..._buildMenuButtons(buttonStyle),
                ],
              ),
            ),
          ),

          // 右下角版號
          Positioned(
            bottom: 12,
            right: 12,
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuButtons(ButtonStyle style) {
    final labels = [
      "開始遊戲",
      "難度選擇",
      "遊戲簡介",
      "排行榜",
      "角色選擇",
      "商店",
      "音效設定"
    ];

    return labels.map((label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () async {
              await _playClickSound();

              if (label == "開始遊戲") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage()));
              } else if (label == "音效設定") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              } else if (label == "難度選擇") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DifficultyPage()));
              } else if (label == "遊戲簡介") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage()));
              } else if (label == "排行榜") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardPage()));
              } else if (label == "角色選擇") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterSelectPage()));
              } else if (label == "商店") {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage()));
                _loadCoins(); // 回來後刷新金幣顯示
              }
            },
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _circleDeco(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
