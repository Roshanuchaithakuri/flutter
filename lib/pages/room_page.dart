import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../widgets/schedule_bottom_sheet.dart';

abstract class RoomPage extends StatefulWidget {
  final Room room;
  final List<Device> defaultDevices;

  const RoomPage({
    Key? key,
    required this.room,
    required this.defaultDevices,
  }) : super(key: key);
}

abstract class RoomPageState<T extends RoomPage> extends State<T> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDevices();
  }

  Future<void> _initializeDevices() async {
    setState(() => _isLoading = true);

    try {
      final devices = await _firebaseService.getDevicesForRoom(widget.room.id).first;
      
      if (devices.isEmpty) {
        for (final device in widget.defaultDevices) {
          await _firebaseService.addDevice(device);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing devices: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showScheduleDialog(Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScheduleBottomSheet(
          device: device,
          firebaseService: _firebaseService,
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      case 'wifi':
        return Icons.wifi;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'microwave':
        return Icons.microwave;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'dry':
        return Icons.dry;
      case 'wind_power':
        return Icons.wind_power;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.room.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Device>>(
              stream: _firebaseService.getDevicesForRoom(widget.room.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final devices = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getIconData(device.icon)),
                        title: Text(device.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: device.isActive,
                              onChanged: (value) async {
                                await _firebaseService.toggleDevice(
                                  device.id,
                                  value,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.schedule),
                              onPressed: () => _showScheduleDialog(device),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _firebaseService.deleteDevice(device.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}