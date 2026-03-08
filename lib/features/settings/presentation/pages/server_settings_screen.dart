import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:twizzle/core/config/app_config.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _ngrokController = TextEditingController();
  late Box _settingsBox;
  bool _isLoading = true;
  bool _useNgrok = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('settings');
    _ipController.text = _settingsBox.get('serverIp') ?? AppConfig.serverIp;
    _portController.text = (_settingsBox.get('serverPort') ?? AppConfig.serverPort).toString();
    _ngrokController.text = _settingsBox.get('ngrokUrl') ?? '';
    _useNgrok = _settingsBox.get('useNgrok') ?? false;
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (_useNgrok) {
      final url = _ngrokController.text.trim();
      if (url.isEmpty || !url.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid ngrok URL (starts with https://)')),
        );
        return;
      }
      await _settingsBox.put('ngrokUrl', url);
      await _settingsBox.put('useNgrok', true);
    } else {
      final ip = _ipController.text.trim();
      final port = int.tryParse(_portController.text.trim());
      if (ip.isEmpty || port == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid IP and Port')),
        );
        return;
      }
      await _settingsBox.put('serverIp', ip);
      await _settingsBox.put('serverPort', port);
      await _settingsBox.put('useNgrok', false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Settings saved! Restart the app to apply.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Network Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode toggle
            Row(
              children: [
                const Text('Use ngrok (mobile data / no WiFi)', style: TextStyle(fontSize: 15)),
                const Spacer(),
                Switch(
                  value: _useNgrok,
                  onChanged: (v) => setState(() => _useNgrok = v),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            if (_useNgrok) ...[
              const Text(
                '📱 ngrok Mode\nPaste the ngrok URL from your ngrok terminal window.\nExample: https://abc123.ngrok-free.app',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ngrokController,
                decoration: const InputDecoration(
                  labelText: 'ngrok URL',
                  hintText: 'https://xxxx.ngrok-free.app',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const Text(
                '🏠 Local WiFi Mode\nEnter your PC\'s local IP. Phone and PC must be on same WiFi.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 How to find your IP:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('1. Open cmd on your PC.', style: TextStyle(fontSize: 12)),
                    Text('2. Type "ipconfig" and press Enter.', style: TextStyle(fontSize: 12)),
                    Text('3. Look for "IPv4 Address" (e.g. 192.168.x.x).', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'Server IP',
                  hintText: 'e.g. 192.168.18.13',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Server Port',
                  hintText: 'e.g. 5050',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save and Apply'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _useNgrok = false;
                  _ipController.text = AppConfig.serverIp;
                  _portController.text = AppConfig.serverPort.toString();
                  _ngrokController.text = '';
                });
              },
              child: const Text('Reset to Default'),
            ),
          ],
        ),
      ),
    );
  }
}
