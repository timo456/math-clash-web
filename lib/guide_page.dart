import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲簡介'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🟢 遊戲標題卡片
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.teal[50],
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.videogame_asset, size: 72, color: Colors.teal),
                    const SizedBox(height: 10),
                    Text(
                      '歡迎來到 MATH CLASH！',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '一場結合數學與策略的冒險之旅！',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📘 四張遊戲說明卡片
            _infoCard(
              icon: Icons.swipe,
              title: '角色移動',
              content: '透過滑動螢幕控制主角左右移動，選擇最有利的數學閘門通過。',
            ),
            _infoCard(
              icon: Icons.calculate,
              title: '數學閘門',
              content: '閘門包含 +、-、×、÷、^、%、? 等多種效果，會改變人數或造成隨機事件。',
            ),
            _infoCard(
              icon: Icons.sports_kabaddi,
              title: 'Boss 圍攻',
              content: '關卡尾端角色會自動包圍 Boss 並發動攻擊，角色越多傷害越高。',
            ),
            _infoCard(
              icon: Icons.auto_awesome,
              title: '特殊效果',
              content: '隨機閘門 (?) 有機會觸發角色變形、炸彈、分數加倍、顛倒控制等特殊效果。',
            ),
            _infoCard(
              icon: Icons.store,
              title: '商店道具',
              content: '可購買速度提升、護盾（+5 血）、火力加倍（攻擊 x2），每局自動消耗一次。',
            ),
            _infoCard(
              icon: Icons.trending_up,
              title: '難度模式',
              content: '提供簡單、中等、困難、地獄四種難度，Boss 血量與分數倍率會跟著提升。',
            ),
            _infoCard(
              icon: Icons.emoji_events,
              title: '排行榜',
              content: '過關後可輸入暱稱上榜，與其他玩家一較高下，爭奪最高分紀錄！',
            ),

          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(icon, size: 30, color: Colors.teal[600]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text(content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
