import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DifficultyPage extends StatefulWidget {
  const DifficultyPage({super.key});

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends State<DifficultyPage> {
  String? selected;

  Future<void> _setDifficulty(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', level);
    setState(() {
      selected = level;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已選擇「$level」難度')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selected = prefs.getString('difficulty') ?? '中等';
    });
  }

  @override
  Widget build(BuildContext context) {
    final difficulties = [
      {
        'label': '簡單',
        'desc': '👶 適合新手：敵人血少，起始人數多，得分倍率 1.0x',
        'icon': Icons.sentiment_satisfied_alt
      },
      {
        'label': '中等',
        'desc': '⚖️ 平衡挑戰：人數與敵人相當，得分倍率 1.5x',
        'icon': Icons.sentiment_neutral
      },
      {
        'label': '困難',
        'desc': '😓 高手入門：人數少、敵人血厚，得分倍率 2.0x',
        'icon': Icons.sentiment_very_dissatisfied
      },
      {
        'label': '地獄',
        'desc': '🔥 地獄模式：開局人少、Boss超硬，得分倍率 5.0x',
        'icon': Icons.warning_amber_rounded
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('難度選擇'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: difficulties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = difficulties[index];
          final isSelected = selected == item['label'];

          return GestureDetector(
            onTap: () => _setDifficulty(item['label'].toString()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade100])
                    : LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))]
                    : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 3))],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item['icon'] as IconData, size: 36, color: Colors.deepPurple),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item['label'].toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['desc']
                                    .toString()
                                    .split('得分倍率')
                                    .last
                                    .replaceAll('x', ''),
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['desc'].toString().split('：').last.split('得分倍率').first.trim(),
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
