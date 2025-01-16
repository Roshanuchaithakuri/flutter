import 'package:flutter/material.dart';
import '../widgets/base_room_page.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  final devices = [
    DeviceButton(name: 'Induction', icon: Icons.local_fire_department),
    DeviceButton(name: 'Lights', icon: Icons.lightbulb_outline),
    DeviceButton(name: 'Air conditioner', icon: Icons.ac_unit),
    DeviceButton(name: 'Oven', icon: Icons.microwave_outlined),
  ];

  void _handleDeviceToggle(int index, bool value) {
    setState(() {
      devices[index].isActive = value;
      // Here you would add your device control logic
      print('Toggling ${devices[index].name} to $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseRoomPage(
      title: 'Kitchen',
      devices: devices,
      onDeviceToggle: _handleDeviceToggle,
    );
  }
}