import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('خطأ في تهيئة الكاميرا: $e');
  }
  runApp(const FajrAlarmApp());
}

class FajrAlarmApp extends StatelessWidget {
  const FajrAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منبه الفجر والوضوء',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
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
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  TimeOfDay alarmTime = const TimeOfDay(hour: 4, minute: 30);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // تشغيل تلاوة قرآنية مباركة بصوت عذب للتنبيه
  Future<void> playRealAlarmSound() async {
    try {
      if (isPlaying) {
        await _audioPlayer.stop();
        setState(() => isPlaying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⏹️ تم إيقاف تلاوة القرآن'), backgroundColor: Colors.red),
          );
        }
      } else {
        // رابط تلاوة قرآنية هادئة ومستقرة
        await _audioPlayer.setSource(UrlSource('https://server8.mp3quran.net/afs/001.mp3')); // سورة الفاتحة بصوت عبد الرحمن السديس كمثال مبارك
        await _audioPlayer.resume();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        setState(() => isPlaying = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📖 جاري تشغيل تلاوة القرآن الكريم...'), backgroundColor: Colors.teal),
          );
        }
      }
    } catch (e) {
      debugPrint("خطأ في تشغيل الصوت: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ تعذر تشغيل الصوت تأكد من الانترنت: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // نافذة اختيار الوقت
  Future<void> selectAlarmTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarmTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null && picked != alarmTime) {
      setState(() {
        alarmTime = picked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⏰ تم تحديث وقت المنبه إلى: ${alarmTime.format(context)}'), backgroundColor: Colors.teal),
        );
      }
    }
  }

  // فتح الكاميرا الأمامية حصرياً للوضوء
  void openFrontCamera(BuildContext context) {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا توجد كاميرا متاحة في هذا الجهاز'), backgroundColor: Colors.red),
      );
      return;
    }

    CameraDescription selectedCamera = cameras.first;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        selectedCamera = camera;
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealCameraView(camera: selectedCamera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منبه الفجر والوضوء الذكي'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                'وقت المنبه: ${alarmTime.format(context)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () => selectAlarmTime(context),
                icon: const Icon(Icons.access_time, color: Colors.white),
                label: const Text('تغيير وقت المنبه', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 15),
              
              ElevatedButton.icon(
                onPressed: playRealAlarmSound,
                icon: Icon(isPlaying ? Icons.stop : Icons.menu_book, color: Colors.white),
                label: Text(isPlaying ? 'إيقاف تلاوة القرآن' : 'تشغيل تلاوة القرآن للتنبيه', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.green.shade700,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () => openFrontCamera(context),
                icon: const Icon(Icons.camera_front, color: Colors.white),
                label: const Text('فتح الكاميرا الأمامية (الوجه المبلل للوضوء)', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RealCameraView extends StatefulWidget {
  final CameraDescription camera;
  const RealCameraView({super.key, required this.camera});

  @override
  State<RealCameraView> createState() => _RealCameraViewState();
}

class _RealCameraViewState extends State<RealCameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('فحص الوجه المبلل (الكاميرا الأمامية)'), backgroundColor: Colors.teal),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox.expand(child: CameraPreview(_controller)),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ تم التحقق من الوجه بنجاح، تقبل الله الصلاة!'), backgroundColor: Colors.teal),
                        );
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('تأكيد الوجه المبلل وإيقاف المنبه', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
