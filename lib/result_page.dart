import 'package:flutter/material.dart';
import 'package:math_clash/score_firestore.dart';
import 'home_page.dart';
import 'coin_helper.dart';


class ResultPage extends StatefulWidget {
  final int player;
  final int blood;
  final bool win;
  final int score;

  const ResultPage({
    super.key,
    required this.player,
    required this.blood,
    required this.win,
    required this.score,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showVictoryAnim = false;
  bool _showDefeatAnim = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        if (widget.win) {
          _showVictoryAnim = true;
        } else {
          _showDefeatAnim = true;
        }
      });
    });
  }

  void _saveAndBack() async {
    final name = _nameController.text.trim().isEmpty ? '無名玩家' : _nameController.text;

    try {
      await ScoreFirestore.insertScore(name, widget.score);

      // ✅ 若贏得比賽，加金幣獎勵
      if (widget.win) {
        await CoinHelper.addCoins(50); // 加 50 金幣
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 勝利獎勵：獲得 50 金幣！')),
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗：$e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false, // ❌ 禁止返回
    child: Scaffold(
    appBar: AppBar(
    title: const Text('🎮 遊戲結算'),
    automaticallyImplyLeading: false, // ❌ 不顯示返回箭頭
      ),
    body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.win)
                  AnimatedScale(
                    duration: Duration(milliseconds: 800),
                    scale: _showVictoryAnim ? 1.0 : 0.0,
                    curve: Curves.elasticOut,
                    child: Icon(Icons.emoji_events, size: 120, color: Colors.amber),
                  ),
                if (!widget.win)
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 800),
                    opacity: _showDefeatAnim ? 1.0 : 0.0,
                    child: Icon(Icons.sentiment_very_dissatisfied, size: 120, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.win ? '🎉 你贏了！' : '😢 你失敗了',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 28, color: Colors.blue),
                const SizedBox(width: 8),
                Text('剩餘小人數量：${widget.player}', style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.heart_broken, size: 28, color: Colors.red),
                const SizedBox(width: 8),
                Text('Boss 剩餘血量：${widget.blood < 0 ? 0 : widget.blood}', style: TextStyle(fontSize: 20)),
              ],
            ),
            const Divider(height: 40, thickness: 2),
            Text('最終得分：${widget.score}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '👤 請輸入你的名字',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveAndBack,
              icon: const Icon(Icons.save),
              label: const Text('儲存並返回首頁'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
