// lib/services/device_service.dart
import 'package:web_socket_channel/io.dart';

class DeviceService {
  static const String _wsUrl = 'ws://YOUR_ESP32_IP:81'; // Replace with your ESP32's IP
  IOWebSocketChannel? _channel;
  bool _isConnected = false;

  Future<bool> checkDeviceConnection() async {
    try {
      _channel = IOWebSocketChannel.connect(_wsUrl);
      await _channel?.ready;
      _isConnected = true;
      _setupListeners();
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  void _setupListeners() {
    _channel?.stream.listen(
      (message) {
        print('Received from ESP32: $message');
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isConnected = false;
      },
      onDone: () {
        print('WebSocket connection closed');
        _isConnected = false;
      },
    );
  }

  Future<bool> toggleDevice(String deviceName, bool value) async {
    if (!_isConnected || _channel == null) {
      await checkDeviceConnection();
      if (!_isConnected) return false;
    }

    try {
      if (deviceName.toLowerCase() == 'lights') {
        _channel?.sink.add(value ? 'ON' : 'OFF');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling device: $e');
      return false;
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}