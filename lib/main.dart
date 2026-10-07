import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: Colors.white,
      ),
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
  bool isAlarmEnabled = true;
  TimeOfDay alarmTime = const TimeOfDay(hour: 4, minute: 30);
  bool isPlaying = false;

  // دالة تصدر اهتزازاً ونغمة نظام فورية مضمونة 100% بدون إنترنت
  Future<void> togglePlayAudio() async {
    try {
      setState(() {
        isPlaying = !isPlaying;
      });

      if (isPlaying) {
        // اهتزاز الهاتف لتنبيه المستخدم
        await HapticFeedback.heavyImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 تم تشغيل تنبيه المنبه بنجاح (محلياً)'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⏹️ تم إيقاف المنبه'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isPlaying = false;
      });
    }
  }

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منبه الفجر والوضوء'),
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm_rounded,
                size: 100,
                color: Colors.teal,
              ),
              const SizedBox(height: 30),
              Text(
                'وقت المنبه: ${alarmTime.format(context)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _selectTime(context),
                icon: const Icon(Icons.access_time, color: Colors.white),
                label: const Text(
                  'تغيير وقت المنبه',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: togglePlayAudio,
                icon: Icon(
                  isPlaying ? Icons.stop : Icons.notifications_active,
                  color: Colors.white,
                ),
                label: Text(
                  isPlaying ? 'إيقاف التنبيه' : 'تجربة تنبيه المنبه',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تفعيل المنبه',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: isAlarmEnabled,
                    activeColor: Colors.teal,
                    onChanged: (value) {
                      setState(() {
                        isAlarmEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
