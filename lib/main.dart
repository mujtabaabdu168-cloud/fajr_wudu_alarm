import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

void main() {
  runApp(const FajrAlarmApp());
}

class FajrAlarmApp extends StatelessWidget {
  const FajrAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منبه الفجر',
      debugShowCheckedModeBanner: false,
      home: const FajrHomePage(),
    );
  }
}

class FajrHomePage extends StatefulWidget {
  const FajrHomePage({super.key});

  @override
  State<FajrHomePage> createState() => _FajrHomePageState();
}

class _FajrHomePageState extends State<FajrHomePage> {
  bool isPlaying = false;

  // دالة تشغيل نغمة المنبه الحقيقية من داخل الهاتف
  void playAlarm() {
    FlutterRingtonePlayer.playAlarm(
      asAlarm: true,
      looping: true,
      volume: 1.0,
    );
    setState(() => isPlaying = true);
  }

  // دالة إيقاف المنبه
  void stopAlarm() {
    FlutterRingtonePlayer.stop();
    setState(() => isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منبه الفجر المضمون'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm, size: 90, color: Colors.teal),
                const SizedBox(height: 30),
                const Text(
                  'اضغط الزر أدناه لتجربة صوت المنبه:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isPlaying ? stopAlarm : playAlarm,
                  icon: Icon(isPlaying ? Icons.stop : Icons.volume_up, color: Colors.white),
                  label: Text(
                    isPlaying ? 'إيقاف المنبه الآن' : 'تشغيل نغمة المنبه الحقيقية',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlaying ? Colors.red : Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
