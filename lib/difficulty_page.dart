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
      {'label': '簡單', 'desc': '適合初學者，敵人血少，人數多', 'icon': Icons.sentiment_satisfied_alt},
      {'label': '中等', 'desc': '標準挑戰，平衡人數與敵人', 'icon': Icons.sentiment_neutral},
      {'label': '困難', 'desc': '人數少，敵人血多，難度最高', 'icon': Icons.sentiment_very_dissatisfied},
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
            child: Card(
              elevation: isSelected ? 6 : 2,
              color: isSelected ? Colors.deepPurple.shade100 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, size: 36, color: Colors.deepPurple),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'].toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'].toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
