// lib/pages/living_room_page.dart
import 'package:flutter/material.dart';
import '../widgets/base_room_page.dart';
import '../services/device_service.dart';

class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {
  final DeviceService _deviceService = DeviceService();
  late final List<DeviceButton> devices;

  @override
  void initState() {
    super.initState();
    devices = [
      DeviceButton(name: 'WI-FI', icon: Icons.wifi),
      DeviceButton(name: 'Lights', icon: Icons.lightbulb_outline),
      DeviceButton(name: 'Air conditioner', icon: Icons.ac_unit),
      DeviceButton(name: 'Smart TV', icon: Icons.tv),
    ];
    _checkDeviceConnection();
  }

  Future<void> _checkDeviceConnection() async {
    final isConnected = await _deviceService.checkDeviceConnection();
    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect to ESP32. Please check your connection.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleDeviceToggle(int index, bool value) async {
    final device = devices[index];
    
    if (device.name == 'Lights') {
      try {
        final success = await _deviceService.toggleDevice(device.name, value);
        if (success) {
          setState(() {
            devices[index].isActive = value;
          });
        } else {
          _showError('Failed to toggle ${device.name.toLowerCase()}');
        }
      } catch (e) {
        _showError('Error occurred while toggling ${device.name.toLowerCase()}');
      }
    } else {
      // Handle other devices
      setState(() {
        devices[index].isActive = value;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseRoomPage(
      title: 'Living Room',
      devices: devices,
      onDeviceToggle: _handleDeviceToggle,
    );
  }
}