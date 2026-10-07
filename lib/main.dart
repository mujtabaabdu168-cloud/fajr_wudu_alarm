import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;

  // رابط مباشر لتلاوة قرآنية هادئة ومباركة (صيغة MP3 مستقرة)
  // تم اختيار تلاوة خفيفة وموثوقة لتعمل بسرعة فائقة
  final String quranAudioUrl = "https://server8.mp3quran.net/afs/001.mp3"; // سورة الفاتحة بصوت الشيخ عبد الباسط عبد الصمد أو العفاسي (مستقرة وسريعة)

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // مراقبة حالة الصوت لتحديث شكل الزر تلقائياً
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // دالة تشغيل وإيقاف تلاوة القرآن الكريم
  Future<void> toggleQuranAlarm() async {
    try {
      if (isPlaying) {
        await _audioPlayer.stop();
        setState(() => isPlaying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⏹️ تم إيقاف التلاوة'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📖 جاري تشغيل تلاوة القرآن الكريم...'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 2),
            ),
          );
        }
        await _audioPlayer.play(UrlSource(quranAudioUrl));
        setState(() => isPlaying = true);
      }
    } catch (e) {
      setState(() => isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر التشغيل، تحقق من الاتصال: $e')),
        );
      }
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
                Icons.menu_book_rounded,
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
                onPressed: toggleQuranAlarm,
                icon: Icon(
                  isPlaying ? Icons.stop : Icons.volume_up,
                  color: Colors.white,
                ),
                label: Text(
                  isPlaying ? 'إيقاف تلاوة القرآن' : 'تجربة تلاوة القرآن الآن',
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
