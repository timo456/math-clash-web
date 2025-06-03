import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  final List<Map<String, dynamic>> characters = [
    {'name': '火焰小子', 'icon': Icons.whatshot, 'color': Colors.red},
    {'name': '冰霜女孩', 'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'name': '閃電戰士', 'icon': Icons.flash_on, 'color': Colors.amber},
    {'name': '神秘忍者', 'icon': Icons.nightlight_round, 'color': Colors.deepPurple},
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedCharacter();
  }

  Future<void> _loadSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('selectedCharacter') ?? 0;
    });
  }

  Future<void> _selectCharacter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedCharacter', index);
    setState(() {
      selectedIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已選擇角色：${characters[index]['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('角色選擇')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '請選擇你的角色：',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: characters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () => _selectCharacter(index),
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected ? character['color'].withOpacity(0.8) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isSelected
                            ? BorderSide(color: character['color'], width: 3)
                            : BorderSide.none,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(character['icon'], size: 48, color: character['color']),
                          const SizedBox(height: 12),
                          Text(
                            character['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
