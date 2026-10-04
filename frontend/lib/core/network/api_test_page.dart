
import 'package:flutter/material.dart';

import 'api_client.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiClient _apiClient = ApiClient();

  String _status = 'Checking backend connection...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final result = await _apiClient.healthCheck();

      if (!mounted) return;

      setState(() {
        _status = result['message']?.toString() ??
            'Backend connected successfully.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = 'Connection failed: $error';
      });
    }
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _status,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}