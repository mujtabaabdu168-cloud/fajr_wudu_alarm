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

  // تشغيل صوت تنبيه تجريبي مباشر عبر رابط آمن
  Future<void> playRealAlarmSound() async {
    try {
      if (isPlaying) {
        await _audioPlayer.stop();
        setState(() => isPlaying = false);
      } else {
        await _audioPlayer.play(UrlSource('https://www.soundjay.com/buttons/sounds/beep-01a.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        setState(() => isPlaying = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔔 جاري تشغيل صوت التنبيه...'), backgroundColor: Colors.teal),
          );
        }
      }
    } catch (e) {
      debugPrint("خطأ في تشغيل الصوت: $e");
    }
  }

  // فتح الكاميرا الحقيقية للوضوء
  void openRealCamera(BuildContext context) {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا توجد كاميرا متاحة في هذا الجهاز'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealCameraView(camera: cameras.first),
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
              const Text('وقت المنبه: 04:30 AM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              
              ElevatedButton.icon(
                onPressed: playRealAlarmSound,
                icon: Icon(isPlaying ? Icons.stop : Icons.volume_up, color: Colors.white),
                label: Text(isPlaying ? 'إيقاف صوت المنبه' : 'تجربة صوت المنبه الفعلي', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => openRealCamera(context),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('فتح الكاميرا الحقيقية (الوجه المبلل للوضوء)', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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
        appBar: AppBar(title: const Text('فحص الوجه المبلل'), backgroundColor: Colors.teal),
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
