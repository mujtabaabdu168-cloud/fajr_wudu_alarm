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
          crossAxisAlignment: CrossAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }
}
