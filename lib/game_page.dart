import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';



class Gate {
  double x; // -1.0 (左), 1.0 (右)
  double y;
  String op;
  int value;
  bool used;
  Gate(this.x, this.y, this.op, this.value) : used = false;
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}


class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  double playerX = 0;
  int people = 10;
  int score = 0;
  int level = 1;
  double backgroundOffset = 0;
  Timer? gameTimer;
  List<Gate> gates = [];
  int runFrame = 0; // 用來控制小人動畫幀
  int frameTick = 0;
  bool facingLeft = true;
  double targetX = 0; // 目標位置
  Timer? moveTimer;
  double playerAngle = 0.0; // 以弧度表示
  Offset? targetPosition;
  int enemyCount = 20; // 可以動態算
  int generatedGateBlock = 0; // 已產生幾組 gate 區段
  bool enemyAppeared = false;
  double enemyY = -1.2; // 初始在畫面外
  int enemyFrame = 0;
  int enemyTick = 0;
  double roundCounts = 2;
  bool bossBattle = false;
  double circleOffsetY = 160.0; // 小人圓形的 Y 座標中心
  bool preBattle = false;
  int bossHP = 25; // 總血量
  bool attackStarted = false; // 小人是否開始攻擊
  List<Offset> flyingPeople = []; // 飛出去的小人位置
  List<int> flyingTicks = []; // 每個飛出去小人的飛行幀數
  bool finished = false;
  List<Offset> _scatterOffsets = [];
  int maxBossHP = 25;
  double _enemyShakeOffset = 0.0;

  // 🧍‍♂️ 玩家角色圖示
  bool characterSelected = false; // 👈 新增
  IconData playerIcon = Icons.directions_run;
  Color playerColor = Colors.black;

  bool speedBoost = false;
  bool shield = false;
  bool powerUp = false;

  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _walkPlayer = AudioPlayer();
  final AudioPlayer _bossBgmPlayer = AudioPlayer();
  bool bossMusicPlayed = false;

  late AnimationController _gateColorController;
  late Animation<Color?> _rainbowColor;

  String gateMessage = '';
  Timer? gateMessageTimer;

  String levelMessage = '';
  Timer? levelMessageTimer;


  double _calculateWalkVolume() {
    // 最大音量為 1.0，最小為 0.1
    // 設定 50 人以上最大聲
    int maxPeople = 50;
    double minVolume = 0.1;
    double maxVolume = 1.0;

    double ratio = people / maxPeople;
    ratio = ratio.clamp(0.0, 1.0); // 限制在 0~1 範圍
    return minVolume + (maxVolume - minVolume) * ratio;
  }

  void _showGateMessage(String message) {
    gateMessageTimer?.cancel(); // 清除之前的 timer
    setState(() {
      gateMessage = message;
    });

    gateMessageTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        gateMessage = '';
      });
    });
  }

  void _consumeActivatedItems() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < 3; i++) {
      bool isActive = prefs.getBool('active_$i') ?? false;
      int count = prefs.getInt('count_$i') ?? 0;

      if (isActive && count > 0) {
        count--;
        await prefs.setInt('count_$i', count);

        if (count == 0) {
          await prefs.setBool('active_$i', false); // 自動關閉啟用狀態
        }
      }
    }
  }

  Future<void> _playBossBattleMusic() async {
    try {
      await _bossBgmPlayer.stop(); // ⛑ 保險起見
      await _bossBgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bossBgmPlayer.play(
        AssetSource('sounds/boss_battle.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      print('❌ 播放 Boss 音樂失敗: $e');
    }
  }

  Future<void> _stopBossBattleMusic() async {
    await _bossBgmPlayer.stop();
  }

  Future<void> _playVoice(String fileName) async {
    await _voicePlayer.play(AssetSource('sounds/$fileName'),  volume: 0.3);
  }

  Future<void> _startWalkingSound(double volume) async {
    try {
      await _walkPlayer.setReleaseMode(ReleaseMode.loop); // 🔁 連續播放
      await _walkPlayer.play(
        AssetSource('sounds/run.mp3'),
        volume: volume,
      );
    } catch (e) {
      print('❌ 走路聲播放失敗: $e');
    }
  }

  Future<void> _stopWalkingSound() async {
    await _walkPlayer.stop();
  }

  List<Offset> _calculatePeoplePositions() {
    List<Offset> positions = [];
    final screenWidth = MediaQuery.of(context).size.width;
    double groupOffsetX = (playerX + 1) * screenWidth / 2 - 60;

    for (int i = 0; i < _scatterOffsets.length; i++) {
      final offset = _scatterOffsets[i];

      double dxWiggle = 5 * sin((frameTick + i * 10) * 0.1);
      double dyWiggle = 3 * cos((frameTick + i * 15) * 0.1);

      double x = groupOffsetX + offset.dx + dxWiggle;
      double y = 120.0 + offset.dy + dyWiggle; // ✅ 這裡改成「相對底部」
      positions.add(Offset(x, y));
    }

    return positions;
  }



  Future<void> _loadShopEffects() async {
    final prefs = await SharedPreferences.getInstance();
    speedBoost = prefs.getBool('active_0') ?? false;
    shield = prefs.getBool('active_1') ?? false;
    powerUp = prefs.getBool('active_2') ?? false;
  }


  void applyDifficultySetting(String difficulty) {
    int extraHP = shield ? 5 : 0;

    if (difficulty == '簡單') {
      people = 20;
      roundCounts = 7;
      bossHP = 15 - extraHP;
      maxBossHP = 15 - extraHP;
    } else if (difficulty == '中等') {
      people = 10;
      roundCounts = 6;
      bossHP = 25 - extraHP;
      maxBossHP = 25 - extraHP;
    } else if (difficulty == '困難') {
      people = 7;
      roundCounts = 5;
      bossHP = 35 - extraHP;
      maxBossHP = 35 - extraHP;
    }
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('score') ?? 0;
    });
  }


  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    String difficulty = prefs.getString('difficulty') ?? '中等';

    setState(() {
      applyDifficultySetting(difficulty);
    });
  }



  @override
  void initState() {
    super.initState();
    bossMusicPlayed = false; // ✅ 重置
    _loadSelectedCharacter();
    _loadScore(); // ✅ 加這一行
    _startGameLoop();
    _generateScatterOffsets();
    _loadShopEffects();
    _consumeActivatedItems(); // ✅ 自動消耗
    _loadDifficulty();

    _gateColorController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rainbowColor = _gateColorController.drive(
      ColorTween(begin: Colors.teal, end: Colors.pinkAccent),
    );

    moveTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (targetPosition != null && !preBattle) {
        if (targetPosition != null && !preBattle) {
          double volume = _calculateWalkVolume();
          if (_walkPlayer.state != PlayerState.playing) {
            _startWalkingSound(volume); // ✅ 傳入音量
          } else {
            _walkPlayer.setVolume(volume); // ✅ 動態調整音量
          }
        }

        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        double newTargetX = (targetPosition!.dx / screenWidth) * 2 - 1.0;
        newTargetX = newTargetX.clamp(-10.0, 10.0);
        double dx = targetPosition!.dx - screenWidth / 2;
        double dy = targetPosition!.dy - (screenHeight - 100);

        setState(() {
          double moveSpeed = speedBoost ? 0.16 : 0.08; // ⚡ 道具加速
          playerX += (newTargetX - playerX) * moveSpeed;
          facingLeft = dx < 0;
          playerAngle = atan2(dy, dx);
        });
      }
    });
    // 👇 第一次遊戲開始時顯示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        levelMessage = '🎯 第 $level 關開始！';
      });

      levelMessageTimer?.cancel();
      levelMessageTimer = Timer(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            levelMessage = '';
          });
        }
      });

    });
  }

  Future<void> _loadSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    int selected = prefs.getInt('selectedCharacter') ?? -1;

    List<IconData> icons = [Icons.whatshot, Icons.ac_unit, Icons.flash_on, Icons.nightlight_round];
    List<Color> colors = [Colors.red, Colors.cyan, Colors.amber, Colors.deepPurple];

    setState(() {
      if (selected >= 0) {
        characterSelected = true;
        playerIcon = icons[selected];
        playerColor = colors[selected];
      } else {
        characterSelected = false; // 沒選角
      }
    });
  }


  void _generateMoreGates(int blockIndex) {
    final rand = Random();

    // 加權機率表：越多次代表機率越高
    List<String> opsWeighted = [];

    void _generateOpsWeighted() {
      Map<String, int> opCounts = {
        '+': 35,
        '-': 25,
        '×': 10,
        '/': 10,
        '^': 3,
        '%': 7,
        '?': 10,
      };

      opsWeighted.clear(); // 清除之前的內容（如果你之後會重複執行）
      opCounts.forEach((op, count) {
        opsWeighted.addAll(List.generate(count, (_) => op));
      });
    }

    _generateOpsWeighted();

    double baseY = -1.0 - blockIndex * 0.8;


    // 隨機從 opsWeighted 抽出一個左門符號
    String leftOp = opsWeighted[rand.nextInt(opsWeighted.length)];

    // 過濾出不同於左門的運算符號，再抽一個給右門
    List<String> rightChoices = opsWeighted.where((op) => op != leftOp).toList();
    String rightOp = rightChoices[rand.nextInt(rightChoices.length)];

    // 根據符號決定門的數值範圍
    int getValue(String op) {
      if (op == '^') return rand.nextInt(2) + 2;   // 次方 2~3
      if (op == '%') return rand.nextInt(5) + 2;   // 餘數 2~6
      if (op == '/') return rand.nextInt(4) + 2;   // 除法 2~5
      if (op == '?') return 0;                     // 不需要數值
      return rand.nextInt(5) + 1;                  // 其他 1~5
    }

    // 建立門物件（順序隨機左右交換也可以）
    gates.add(Gate(-1.0, baseY, leftOp, getValue(leftOp)));
    gates.add(Gate(1.0, baseY, rightOp, getValue(rightOp)));
  }



  void _startGameLoop() {
    const double gateWidth = 120;
    const double gateHeight = 80;
    double fallSpeed = speedBoost ? 0.035 : 0.025;
    gameTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      setState(() {
        frameTick++;
        if (frameTick % 6 == 0) {
          runFrame = (runFrame + 1) % 2;
        }
        backgroundOffset += 0.01;

        // ✅ 每段生成門
        if (backgroundOffset > generatedGateBlock * 0.4 &&!enemyAppeared && !preBattle && !bossBattle) {
          _generateMoreGates(generatedGateBlock);
          generatedGateBlock++;
        }

        // ✅ 門移動 & 碰撞處理
        // ✅ 門移動 & 新版碰撞處理（邊緣判定）
        List<Offset> peoplePositions = _calculatePeoplePositions();

        for (var gate in gates) {
          gate.y += fallSpeed;

          if (!gate.used && !enemyAppeared) {
            for (final pos in peoplePositions) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              double gateTop = (1 - gate.y) * screenHeight / 2 - 150 / 2;
              double gateBottom = gateTop + 150;
              double gateLeft = gate.x < 0 ? 0 : screenWidth / 2;
              double gateRight = gate.x < 0 ? screenWidth / 2 : screenWidth;

              if (pos.dx >= gateLeft && pos.dx <= gateRight &&
                  pos.dy >= gateTop && pos.dy <= gateBottom) {
                gate.used = true;

                if (gate.op == '+') {
                  people += gate.value;
                  _showGateMessage('✨ +${gate.value}！人數增加');
                } else if (gate.op == '-') {
                  people = max(0, people - gate.value);
                  _showGateMessage('💀 -${gate.value}！人數減少');
                } else if (gate.op == '×') {
                  people *= gate.value;
                  _showGateMessage('🌀 ×${gate.value}！人數倍增');
                } else if (gate.op == '/') {
                  people = (people / gate.value).floor();
                  _showGateMessage('➗ ÷${gate.value}！人數除法');
                } else if (gate.op == '^') {
                  people = pow(people, gate.value).toInt();
                  _showGateMessage('🔥 ^${gate.value}！超強變化');
                } else if (gate.op == '%') {
                  people %= gate.value;
                  _showGateMessage('🧮 %${gate.value}！取餘數');
                } else if (gate.op == '?') {
                  int randomEffect = Random().nextInt(4);
                  if (randomEffect == 0) {
                    people = Random().nextInt(50) + 1;
                    _showGateMessage('🎯 隨機人數！$people人');
                  } else if (randomEffect == 1) {
                    people = 0;
                    people = max(0, people); // ✅ 加這行（雖然已經是 0，為了統一）
                    _showGateMessage('💣 陷阱！全滅！');
                  } else if (randomEffect == 2) {
                    score += 500;
                    _showGateMessage('🎁 獎勵分數 +500！');
                  } else if (randomEffect == 3) {
                    setState(() {
                      characterSelected = true; // ⛑ 保證用到 playerIcon
                      playerIcon = Icons.auto_awesome;
                      playerColor = Colors.pinkAccent;
                    });
                    _showGateMessage('🌀 角色變形！');
                  }
                }


                score += gate.value * 160;

                _generateScatterOffsets();
                break;
              }
            }
          }
        }



        // ✅ 敵人登場（快結束時）
        if (backgroundOffset > roundCounts-0.5) {
          enemyAppeared = true;
          if (!bossMusicPlayed) {
            _playBossBattleMusic(); // ✅ 只會播一次
            bossMusicPlayed = true;
          }
        }

        if (enemyAppeared && !bossBattle) {
          final screenHeight = MediaQuery.of(context).size.height;

          // 🔼 讓 boss 停在圈圈中心「上方」
          double offsetAbove = 40.0;
          double targetEnemyY = (screenHeight - (circleOffsetY + offsetAbove)) / (screenHeight / 2) - 1.0;

          if(preBattle == false){
            enemyY += 0.01;
          }else{
            if(enemyY < targetEnemyY ){
              enemyY += 0.01;
            }else{
              enemyY = targetEnemyY;
              // 🔥✅ 加在這裡：敵人到位後啟動攻擊
              if (!attackStarted) {
                bossBattle = true;
                attackStarted = true;
                _startPeopleAttack(); // ← 第 3 步會寫這個函數
              }
            }
          }

          if (backgroundOffset > roundCounts+0.5) {
            preBattle = true; // ✅ 啟動小人轉圈 + 上升
          }
          // 小人提前往上升
          // 👇 當接近就進入預戰狀態（人開始升）
          if (preBattle && circleOffsetY < 300) {
            // 平滑將 player 移動到中央
            playerX += (-0.045 - playerX) * 0.1;
            circleOffsetY += 2; // 小人逐漸升高
          }
        }
        // 🌀 更新小人飛行動畫
        for (int i = 0; i < flyingPeople.length; i++) {
          flyingTicks[i]++;
          flyingPeople[i] = Offset(flyingPeople[i].dx, flyingPeople[i].dy + 6); // 向上移動
        }

// 🧹 移除飛完的（20 幀後）
        for (int i = flyingPeople.length - 1; i >= 0; i--) {
          if (flyingTicks[i] > 20) {
            flyingPeople.removeAt(i);
            flyingTicks.removeAt(i);
          }
        }
        if (people <= 0 && !finished) {
          finished = true;
          _showGateMessage('⚠️ 全滅！遊戲即將結束');
          Future.delayed(Duration(seconds: 1), _finishGame);
        }

      });
    });
  }

  void _startPeopleAttack() {
    int attackPower = powerUp ? 2 : 1; // ✅ 攻擊道具生效時 *2

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (people <= 0) {
        timer.cancel();
        finished = true;
        _showGateMessage('⚠️ 全滅！遊戲即將結束');
        Future.delayed(const Duration(seconds: 1), _finishGame);
        return;
      }

      if (bossHP <= 0) {
        timer.cancel();
        // ✅ 不跳結束畫面，改為進下一關
        level++;
        score += 1000;
        Future.delayed(const Duration(milliseconds: 500), _finishGame);
        return;
      }

      setState(() {
        bossHP -= attackPower;
        people--;
        people = max(0, people); // 保護人數不會負數
        _playVoice('attack.mp3'); // 👉 加這行

        // ⚡ 觸發 Boss 抖動
        _enemyShakeOffset = 6;
        Future.delayed(Duration(milliseconds: 80), () {
          if (mounted) {
            setState(() {
              _enemyShakeOffset = -6;
            });
          }
        });
        Future.delayed(Duration(milliseconds: 160), () {
          if (mounted) {
            setState(() {
              _enemyShakeOffset = 0;
            });
          }
        });

        double centerX = (playerX + 1) * MediaQuery.of(context).size.width / 2;
        double centerY = circleOffsetY;
        flyingPeople.add(Offset(centerX, centerY));
        flyingTicks.add(0);
      });
    });

  }



  void _finishGame() async {
    gameTimer?.cancel();
    moveTimer?.cancel();
    _stopBossBattleMusic();

    final prefs = await SharedPreferences.getInstance();
    String difficulty = prefs.getString('difficulty') ?? '中等';

    // ✅ 唯一結束條件：人數歸零
    if (people <= 0) {
      _playVoice('fail.mp3');
      await prefs.remove('score');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => ResultPage(
            player: people,
            blood: bossHP,
            win: false,
            score: score,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    // ✅ 若 Boss 被打敗且人還活著 → 進下一關（繼續遊戲）
    _playVoice('win.mp3');
    await prefs.setInt('score', score);

    setState(() {
      applyDifficultySetting(difficulty);
      people = min(people + 5, 20);
      backgroundOffset = 0;
      gates.clear();
      generatedGateBlock = 0;
      bossBattle = false;
      preBattle = false;
      attackStarted = false;
      enemyAppeared = false;
      enemyY = -1.2;
      circleOffsetY = 160.0;
      playerX = -0.045;
      flyingPeople.clear();
      flyingTicks.clear();
      finished = false;
      bossMusicPlayed = false;
      _generateScatterOffsets();
      levelMessage = '🎯 第 $level 關開始！';
      levelMessageTimer?.cancel();
      levelMessageTimer = Timer(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            levelMessage = '';
          });
        }
      });
    });

    moveTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (targetPosition != null && !preBattle) {
        double volume = _calculateWalkVolume();
        if (_walkPlayer.state != PlayerState.playing) {
          _startWalkingSound(volume);
        } else {
          _walkPlayer.setVolume(volume);
        }

        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        double newTargetX = (targetPosition!.dx / screenWidth) * 2 - 1.0;
        newTargetX = newTargetX.clamp(-10.0, 10.0);
        double dx = targetPosition!.dx - screenWidth / 2;
        double dy = targetPosition!.dy - (screenHeight - 100);

        setState(() {
          double moveSpeed = speedBoost ? 0.16 : 0.08;
          playerX += (newTargetX - playerX) * moveSpeed;
          facingLeft = dx < 0;
          playerAngle = atan2(dy, dx);
        });
      }
    });

    _startGameLoop();
  }





  void moveLeft() {
    setState(() {
      playerX = -1;
    });
  }

  void moveRight() {
    setState(() {
      playerX = 1;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();       // ✅ 清除 Timer
    moveTimer?.cancel();       // ✅ 如果還有控制移動的 Timer
    levelMessageTimer?.cancel(); // ✅ 新增這行
    _walkPlayer.dispose();     // ✅ 停止走路聲播放器
    _bossBgmPlayer.dispose(); // ✅ 別忘了這行
    _gateColorController.dispose(); // ✅ 記得關閉動畫
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bossSize = 100.0 + level * 10; // 每關 Boss 越來越大
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanStart: (details) {
          targetPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          targetPosition = details.localPosition;
        },
        onPanEnd: (_) {
          targetPosition = null;
          _stopWalkingSound(); // ✅ 停止走路聲
        },
        child: Stack(
          children: [
            // 背景捲動
            ...List.generate(3, (i) {
              return Positioned(
                top: (i * 600.0 - (backgroundOffset * 600) % 600),
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/road.png',
                  height: 600,
                  fit: BoxFit.cover,
                ),
              );
            }),

            // 門 Gate
            ...gates
                .where((g) => !g.used && !bossBattle && !preBattle && !enemyAppeared)
                .map((gate) => _buildGateWidget(gate)),

            if (preBattle)
              Positioned(
                top: 20,
                left: 60,
                right: 60,
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2), // 👈 外框
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Colors.red, Colors.orange],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: LinearProgressIndicator(
                          value: bossHP / maxBossHP,
                          backgroundColor: Colors.black,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ), // 👈


            // 玩家與小人群
            ..._buildPeople(),

            ...flyingPeople.map((pos) {
              return Positioned(
                bottom: pos.dy,
                left: pos.dx,
                child: Icon(
                  Icons.flash_on,
                  size: 34,
                  color: Colors.redAccent.withOpacity(0.85),
                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.yellowAccent,
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 4,
                      color: Colors.redAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              );
            }).toList(),


            // 玩家人數
            Positioned(
              top: 40,
              left: 20,
              child: Row(
                children: [
                  Icon(Icons.groups, size: 28, color: Colors.black87),
                  SizedBox(width: 6),
                  Text('$people',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Positioned(
              top: 80,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (speedBoost)
                    _buildEffectBadge('⚡速度提升'),
                  if (shield)
                    _buildEffectBadge('🛡️護盾 +5'),
                  if (powerUp)
                    _buildEffectBadge('🔥攻擊x2'),
                ],
              ),
            ),

            // 分數顯示
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: [
                  Icon(Icons.star, size: 28, color: Colors.amber),
                  SizedBox(width: 6),
                  Text('$score',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // 🧨 敵人登場（會從上方掉下來）
            if (enemyAppeared)
              Positioned(
                top: (enemyY + 1) * MediaQuery.of(context).size.height / 2 - 50, // 🟢 從畫面頂部掉下來
                left: (playerX + 1) * MediaQuery.of(context).size.width / 2 - 15 + _enemyShakeOffset, // 🟢 對齊玩家
                child: Image.asset(
                  'assets/enemy.gif',
                  width: bossSize,
                  height: bossSize,
                  fit: BoxFit.cover,
                ),
              ),
            // 門提示訊息（右上角）
            if (gateMessage.isNotEmpty)
              Positioned(
                top: 40,
                right: 20,
                child: AnimatedOpacity(
                  opacity: gateMessage.isNotEmpty ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      gateMessage,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (levelMessage.isNotEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    levelMessage,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.yellowAccent, offset: Offset(0, 0)),
                      ],
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }


  Widget _buildGate(String op, int val) {
    Color baseColor;

    if (op == '+') {
      baseColor = Colors.green;
    } else if (op == '-') {
      baseColor = Colors.red;
    } else if (op == '×' || op == '^') {
      baseColor = Colors.purple;
    } else if (op == '/' || op == '%') {
      baseColor = Colors.orange;
    } else if (op == '?') {
      // 這裡先給一個預設顏色
      baseColor = Colors.teal;
    } else {
      baseColor = Colors.blueGrey;
    }

    if (op == '?') {
      // ⭐ 用 AnimatedBuilder 包住有動畫的門
      return AnimatedBuilder(
        animation: _gateColorController,
        builder: (context, child) {
          return Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: _rainbowColor.value ?? Colors.teal,
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                op == '?' ? '❓' : '$op$val',// ✅ 如果是 ? 就只顯示問號
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // 🧱 一般門回傳這裡
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.85),
        border: Border.all(color: Colors.blueGrey, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$op$val',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGateWidget(Gate gate) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final gateHeight = 150.0;

    // 門的顏色
    Color baseColor;
    switch (gate.op) {
      case '+':
        baseColor = Colors.green;
        break;
      case '-':
        baseColor = Colors.red;
        break;
      case '×':
      case '^':
        baseColor = Colors.purple;
        break;
      case '/':
      case '%':
        baseColor = Colors.orange;
        break;
      case '?':
        baseColor = Colors.teal;
        break;
      default:
        baseColor = Colors.grey;
    }

    double gateTop = (gate.y + 1) * screenHeight / 2 - gateHeight / 2;

    return Positioned(
      top: gateTop,
      left: gate.x < 0 ? 0 : screenWidth / 2,
      width: screenWidth / 2,
      height: gateHeight,
      child: Container(
        decoration: BoxDecoration(
          color: gate.op == '?' ? (_rainbowColor.value ?? baseColor) : baseColor.withOpacity(0.9),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6),
          ],
        ),
        child: Center(
          child: Text(
            gate.op == '?' ? '❓' : '${gate.op}${gate.value}',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
            ),
          ),
        ),
      ),
    );
  }



  List<Widget> _buildPeople() {
    return (bossBattle || preBattle) ? _buildCirclePeople() : _buildScatterPeople();
  }

  List<Widget> _buildScatterPeople() {
    List<Widget> peopleWidgets = [];
    final screenWidth = MediaQuery.of(context).size.width;
    double groupOffsetX = (playerX + 1) * screenWidth / 2 - 60;

    for (int i = 0; i < _scatterOffsets.length; i++) {
      final offset = _scatterOffsets[i];

      // 🔁 加上動態偏移（每個人用不同頻率和幅度晃動）
      double dxWiggle = 5 * sin((frameTick + i * 10) * 0.1);
      double dyWiggle = 3 * cos((frameTick + i * 15) * 0.1);

      peopleWidgets.add(Positioned(
        bottom: 120.0 + offset.dy + dyWiggle,
        left: groupOffsetX + offset.dx + dxWiggle,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(cos(playerAngle) < 0 ? -1.0 : 1.0, 1.0),
          child: characterSelected
              ? Icon(playerIcon, size: 40, color: playerColor)
              : Stack(
            alignment: Alignment.center,
            children: [
              Icon(runFrame == 0 ? Icons.directions_run : Icons.directions_walk, size: 42, color: Colors.black),
              Icon(runFrame == 0 ? Icons.directions_run : Icons.directions_walk_outlined, size: 36, color: Colors.white),
            ],
          ),
        ),
      ));
    }

    return peopleWidgets;
  }


  List<Widget> _buildCirclePeople() {
    List<Widget> peopleWidgets = [];
    final screenWidth = MediaQuery.of(context).size.width;
    int maxPeopleToShow = min(people, 50);

    double centerX = (playerX + 1) * screenWidth / 2;
    double centerY = circleOffsetY;
    double radius = (30 + maxPeopleToShow).toDouble();

    for (int i = 0; i < maxPeopleToShow; i++) {
      double angle = (2 * pi / maxPeopleToShow) * i;
      double x = centerX + cos(angle) * radius;
      double y = centerY + sin(angle) * radius;

      peopleWidgets.add(Positioned(
        bottom: y,
        left: x,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(cos(playerAngle) < 0 ? -1.0 : 1.0, 1.0),
          child: characterSelected
              ? Icon(playerIcon, size: 40, color: playerColor)
              : Stack(
            alignment: Alignment.center,
            children: [
              Icon(runFrame == 0 ? Icons.directions_run : Icons.directions_walk, size: 42, color: Colors.black),
              Icon(runFrame == 0 ? Icons.directions_run : Icons.directions_walk_outlined, size: 36, color: Colors.white),
            ],
          ),
        ),
      ));
    }

    return peopleWidgets;
  }

  void _generateScatterOffsets() {
    final random = Random();
    int currentCount = _scatterOffsets.length;
    int targetCount = min(people, 50);

    // 如果人數增加：加新 offset
    if (targetCount > currentCount) {
      int addCount = targetCount - currentCount;
      _scatterOffsets.addAll(List.generate(
        addCount,
            (_) => Offset(random.nextDouble() * 80 - 40, random.nextDouble() * 60),
      ));
    }

    // 如果人數減少：砍掉尾端
    if (targetCount < currentCount) {
      _scatterOffsets.removeRange(targetCount, currentCount);
    }
  }

  Widget _buildEffectBadge(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }


}

