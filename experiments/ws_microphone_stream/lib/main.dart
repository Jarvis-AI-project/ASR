// Path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'recording_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Permission.microphone.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microphone Stream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Server Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'Server IP'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Server Port'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleCustomServerConnection,
              child: const Text('Connect'),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or', style: TextStyle(fontSize: 16)),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleDevashishServerConnection,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                foregroundColor: Colors.green,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Connect to Devasheesh's hosted server\n",
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    TextSpan(
                      text:
                          'IP: ${dotenv.env['DEVASHISH_SERVER_IP']}, Port: ${dotenv.env['DEVASHISH_SERVER_PORT']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCustomServerConnection() async {
    final status = await Permission.microphone.status;
    if (!mounted) return;

    if (status.isGranted) {
      final serverIp = _ipController.text;
      final serverPort = int.tryParse(_portController.text);
      if (serverIp.isNotEmpty && serverPort != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordingScreen(
              serverIp: serverIp,
              serverPort: serverPort,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid IP and Port')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  Future<void> _handleDevashishServerConnection() async {
    final status = await Permission.microphone.status;
    if (!mounted) return;

    if (status.isGranted) {
      final serverIp = dotenv.env['DEVASHISH_SERVER_IP'];
      final serverPort =
          int.tryParse(dotenv.env['DEVASHISH_SERVER_PORT'] ?? '');
      if (serverIp != null && serverPort != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordingScreen(
              serverIp: serverIp,
              serverPort: serverPort,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Server details not found in environment variables')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }
}
