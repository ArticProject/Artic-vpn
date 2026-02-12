import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ArcticVPN());
}

class ArcticVPN extends StatelessWidget {
  const ArcticVPN({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isConnected = false;
  bool subscriptionActive = true; // подписка активна по умолчанию
  String fakeIP = "0.0.0.0";
  double speed = 0.0;
  double trafficUsed = 0.0;
  final double trafficLimit = 100.0; // ГБ
  Timer? timer;
  late AnimationController rotationController;

  final List<String> fakeIPs = [
    "185.23.44.12",
    "91.203.17.55",
    "45.67.221.90",
    "103.145.88.14",
    "176.98.201.33",
    "185.156.44.78",
  ];

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  void toggleConnection() {
    setState(() {
      isConnected = !isConnected;
    });

    if (isConnected) {
      rotationController.repeat();
      fakeIP = fakeIPs[Random().nextInt(fakeIPs.length)];

      timer = Timer.periodic(const Duration(seconds: 2), (_) {
        setState(() {
          speed = 5 + Random().nextDouble() * 50; // 5–55 Mb/s
          trafficUsed += Random().nextDouble() * 0.5; // +0–0.5 ГБ за 2 сек
          if (trafficUsed > trafficLimit) trafficUsed = trafficLimit;
        });
      });
    } else {
      rotationController.stop();
      timer?.cancel();
      speed = 0.0;
      fakeIP = "0.0.0.0";
    }
  }

  void copyKey() {
    Clipboard.setData(const ClipboardData(text: 'QKZOQOZXYW...WL'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ключ скопирован!')),
    );
  }

  @override
  void dispose() {
    rotationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Arctic VPN',
          style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.telegram, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Облачко
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Text(
                    isConnected
                        ? 'Чтобы выключить VPN нажмите на кнопку'
                        : 'Чтобы подключить VPN нажмите на кнопку',
                    style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Снежинка с анимацией вращения
                GestureDetector(
                  onTap: toggleConnection,
                  child: RotationTransition(
                    turns: rotationController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected ? const Color(0xFF00BFFF) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.ac_unit,
                        size: 50,
                        color: isConnected ? Colors.white : const Color(0xFF00BFFF),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Карточки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InfoCard(title: 'скорость', value: isConnected ? '${speed.toStringAsFixed(1)} Mb/s' : '0.0 Kb/s'),
                    _InfoCard(
                      title: 'до 19.03',
                      value: subscriptionActive ? 'активна' : 'не активна',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Использовано / лимит
                Text(
                  '${trafficUsed.toStringAsFixed(1)} ГБ / 100 ГБ',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 24),

                // Ключ (кликабельный)
                GestureDetector(
                  onTap: copyKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: const Text(
                      'QKZOQOZXYW...WL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00BFFF),
            ),
          ),
        ],
      ),
    );
  }
}
