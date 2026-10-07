import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منبه الفجر والوضوء',
      theme: ThemeData(
        primarySwatch: Colors.teal,
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
  TimeOfDay alarmTime = const TimeOfDay(hour: 4, minute: 30);

  // دالة اختيار الوقت
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarmTime,
    );
    if (picked != null && picked != alarmTime) {
      setState(() {
        alarmTime = picked;
      });
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_alarm,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              'وقت المنبه: ${alarmTime.format(context)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _selectTime(context),
              icon: const Icon(Icons.timer),
              label: const Text('تغيير وقت المنبه'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // زر تجربة التلاوة الخاشعة (قريباً سنربطه بالصوت)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جارٍ تجهيز الآيات الخاشعة للفجر...')),
                );
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('تجربة التلاوة الخاشعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text(
                'تفعيل المنبه',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              value: isAlarmActive,
              activeColor: Colors.teal,
              onChanged: (bool value) {
                setState(() {
                  isAlarmActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
