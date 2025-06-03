import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coin_helper.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final items = ['⚡速度提升', '🛡️護盾', '🔥火力加強'];
  final descriptions = ['小人移動速度加快', 'Boss 戰多撐 5 擊', '攻擊力乘2'];
  int coins = 100;
  static const itemCost = 30;
  List<int> purchaseCounts = [0, 0, 0]; // 與 items 對應
  List<bool> active = [false, false, false]; // 每個道具是否啟用

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 100;
      for (int i = 0; i < items.length; i++) {
        purchaseCounts[i] = prefs.getInt('count_$i') ?? 0;
      }
      for (int i = 0; i < items.length; i++) {
        purchaseCounts[i] = prefs.getInt('count_$i') ?? 0;
        active[i] = prefs.getBool('active_$i') ?? false;
      }
    });
  }


  Future<void> _buyItem(int index) async {
    bool success = await CoinHelper.spendCoins(itemCost);

    if (success) {
      final prefs = await SharedPreferences.getInstance();

      // 增加購買次數
      int currentCount = prefs.getInt('count_$index') ?? 0;
      currentCount++;
      await prefs.setInt('count_$index', currentCount);

      // 更新本地顯示
      setState(() {
        coins -= itemCost;
        purchaseCounts[index] = currentCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功購買：${items[index]}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 金幣不足！')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛒 道具商店')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text('💰 目前金幣：$coins', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          child: Text(items[index][0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[index],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(descriptions[index]),
                              const SizedBox(height: 4),
                              Text('已擁有 ${purchaseCounts[index]} 個', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _buyItem(index),
                                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                                    label: Text('購買 ($itemCost)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      const Text('啟用'),
                                      Switch(
                                        value: active[index],
                                        onChanged: (value) async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (value && purchaseCounts[index] == 0) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('❌ 數量不足，無法啟用')),
                                            );
                                            return;
                                          }
                                          setState(() => active[index] = value);
                                          await prefs.setBool('active_$index', value);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
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
    );
  }
}
