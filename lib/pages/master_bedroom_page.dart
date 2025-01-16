// lib/pages/master_bedroom_page.dart
import 'package:flutter/material.dart';
import '../widgets/base_room_page.dart';

class MasterBedroomPage extends StatefulWidget {
  const MasterBedroomPage({super.key});

  @override
  State<MasterBedroomPage> createState() => _MasterBedroomPageState();
}

class _MasterBedroomPageState extends State<MasterBedroomPage> {
  final devices = [
    DeviceButton(name: 'WI-FI', icon: Icons.wifi),
    DeviceButton(name: 'Lights', icon: Icons.lightbulb_outline),
    DeviceButton(name: 'Air conditioner', icon: Icons.ac_unit),
    DeviceButton(name: 'Smart TV', icon: Icons.tv),
  ];

  void _handleDeviceToggle(int index, bool value) {
    setState(() {
      devices[index].isActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseRoomPage(
      title: 'Master Bedroom',
      devices: devices,
      onDeviceToggle: _handleDeviceToggle,
    );
  }
}

