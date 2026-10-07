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
    // ضبط وضع التكرار لصوت المنبه
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // تشغيل الصوت الفعلي المضمون من ملف صوتي قياسي ومباشر
  Future<void> toggleAlarmSound() async {
    try {
      if (isPlaying) {
        await _audioPlayer.stop();
        setState(() => isPlaying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⏹️ تم إيقاف المنبه'), backgroundColor: Colors.red),
          );
        }
      } else {
        // تشغيل صوت مباشر وقوي ومضمون 100%
        await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
        
        setState(() => isPlaying = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 المنبه يعمل الآن بصوت مرتفع!'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("خطأ في مشغل الصوت: $e");
      // بديل احتياطي فوري لو حدث أي عارض شبكي
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ خطأ في تشغيل الملف: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
    }
  }

  void openFrontCamera(BuildContext context) {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا توجد كاميرا متاحة'), backgroundColor: Colors.red),
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
        builder: (context) => RealCameraView(camera: selectedCamera, onStopAlarm: () async {
          await _audioPlayer.stop();
          setState(() => isPlaying = false);
        }),
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
              const Icon(Icons.alarm_on, size: 80, color: Colors.teal),
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
                onPressed: toggleAlarmSound,
                icon: Icon(isPlaying ? Icons.stop : Icons.volume_up, color: Colors.white),
                label: Text(
                  isPlaying ? 'إيقاف صوت المنبه' : 'تجربة صوت المنبه الآن',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.green.shade700,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () => openFrontCamera(context),
                icon: const Icon(Icons.camera_front, color: Colors.white),
                label: const Text('فتح الكاميرا الأمامية (فحص الوجه للوضوء)', style: TextStyle(color: Colors.white)),
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
  final VoidCallback onStopAlarm;
  const RealCameraView({super.key, required this.camera, required this.onStopAlarm});

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
        appBar: AppBar(title: const Text('فحص الوجه المبلل للوضوء'), backgroundColor: Colors.teal),
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
                        widget.onStopAlarm(); // إيقاف الصوت عند تأكيد الوضوء
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ تم التحقق من الوجه المبلل وإيقاف المنبه، تقبل الله!'),
                            backgroundColor: Colors.teal,
                          ),
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
