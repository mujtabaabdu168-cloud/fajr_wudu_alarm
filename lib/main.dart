import 'package:flutter/material.dart';

void main() {
  runApp(const FajrAlarmApp());
}

class FajrAlarmApp extends StatelessWidget {
  const FajrAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منبه الفجر والوضوء',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAlarmActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منبه الفجر والوضوء'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAlignment.center,
          children: [
            const Icon(
              Icons.access_alarm,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            const Text(
              'موعد منبه الفجر',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '04:30 ص',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('تفعيل المنبه: ', style: TextStyle(fontSize: 18)),
                Switch(
                  value: isAlarmActive,
                  onChanged: (val) {
                    setState(() {
                      isAlarmActive = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تأكيد الوضوء وإيقاف المنبه بنجاح!')),
                );
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('تأكيد الوضوء لإيقاف المنبه'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
