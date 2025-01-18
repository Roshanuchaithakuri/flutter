import 'package:flutter/material.dart';
import '../models/models.dart';
import 'schedule_page.dart';

class RoomPage extends StatefulWidget {
  final Room room;

  const RoomPage({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _createNotification(String title, String message, String type) async {
    final notification = AppNotification(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    await _firebaseService.addNotification(notification);
  }

  void _addDevice() {
    showDialog(
      context: context,
      builder: (context) => AddDeviceDialog(
        onAdd: (String name, String iconName) async {
          final device = Device(
            id: 'device_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            roomId: widget.room.id,
            icon: iconName,
          );
          await _firebaseService.addDevice(device);
          
          // Create notification for device addition
          await _createNotification(
            'Device Added',
            'New device "$name" has been added to ${widget.room.name}',
            'device_added'
          );
          
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        backgroundColor: Colors.purple[400],
      ),
      body: StreamBuilder<List<Device>>(
        stream: _firebaseService.getDevicesForRoom(widget.room.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final devices = snapshot.data!;
          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No devices yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first device by tapping the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) => _buildDeviceCard(devices[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        backgroundColor: Colors.purple[400],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    void _showDeleteConfirmation() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Device'),
          content: Text('Are you sure you want to delete "${device.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firebaseService.deleteDevice(device);
                  
                  // Create notification for device deletion
                  await _createNotification(
                    'Device Deleted',
                    '${device.name} has been removed from ${widget.room.name}',
                    'device_deleted'
                  );
                  
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${device.name} has been deleted')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete device')),
                  );
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      );
    }

    bool hasActiveSchedule() {
      if (device.scheduleStart == null || device.scheduleEnd == null) return false;
      final now = DateTime.now();
      return now.isAfter(device.scheduleStart!) && now.isBefore(device.scheduleEnd!);
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconData(
                  int.parse(device.icon),
                  fontFamily: 'MaterialIcons',
                ),
                size: 40,
                color: device.isActive ? Colors.purple[400] : Colors.grey,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: device.isActive,
                    onChanged: (value) async {
                      await _firebaseService.toggleDevice(device.id, value);
                      
                      // Create notification for device toggle
                      await _createNotification(
                        'Device ${value ? 'Turned On' : 'Turned Off'}',
                        '${device.name} has been turned ${value ? 'on' : 'off'} in ${widget.room.name}',
                        value ? 'device_on' : 'device_off'
                      );
                    },
                    activeColor: Colors.purple[400],
                  ),
                  IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchedulePage(device: device),
                        ),
                      );
                      
                      // Create notification for schedule update if schedule was set
                      if (result == true) {
                        await _createNotification(
                          'Schedule Updated',
                          'Schedule has been set for ${device.name} in ${widget.room.name}',
                          'schedule_set'
                        );
                      }
                    },
                    color: device.scheduleStart != null ? Colors.purple[400] : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
            color: Colors.purple[700],
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ),
      ],
    );
  }
}


class AddDeviceDialog extends StatefulWidget {
  final Function(String name, String icon) onAdd;

  const AddDeviceDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _nameController = TextEditingController();
  String? _selectedIcon;

  final List<Map<String, dynamic>> _availableIcons = [
  // Living Room Devices
  {'name': 'Light', 'icon': Icons.lightbulb_outline.codePoint.toString()},
  {'name': 'AC', 'icon': Icons.ac_unit.codePoint.toString()},
  {'name': 'TV', 'icon': Icons.tv.codePoint.toString()},
  {'name': 'Fan', 'icon': Icons.wind_power.codePoint.toString()},
  {'name': 'Smart Speaker', 'icon': Icons.speaker.codePoint.toString()},
  {'name': 'Media Player', 'icon': Icons.play_circle_outline.codePoint.toString()},

  // Bedroom Devices
  {'name': 'Lamp', 'icon': Icons.light.codePoint.toString()},
  {'name': 'Ceiling Fan', 'icon': Icons.move_up.codePoint.toString()},
  {'name': 'Air Purifier', 'icon': Icons.air_outlined.codePoint.toString()},
  {'name': 'Smart Blinds', 'icon': Icons.blinds.codePoint.toString()},
  {'name': 'Alarm Clock', 'icon': Icons.alarm.codePoint.toString()},

  // Kitchen Devices
  {'name': 'Microwave', 'icon': Icons.microwave.codePoint.toString()},
  {'name': 'Refrigerator', 'icon': Icons.kitchen.codePoint.toString()},
  {'name': 'Coffee Maker', 'icon': Icons.coffee.codePoint.toString()},
  {'name': 'Dishwasher', 'icon': Icons.countertops.codePoint.toString()},
  {'name': 'Oven', 'icon': Icons.local_fire_department.codePoint.toString()},

  // Bathroom Devices
  {'name': 'Exhaust Fan', 'icon': Icons.air.codePoint.toString()},
  {'name': 'Water Heater', 'icon': Icons.hot_tub.codePoint.toString()},

  {'name': 'Towel Warmer', 'icon': Icons.waves.codePoint.toString()},

  // Office Devices
  {'name': 'Desk Lamp', 'icon': Icons.desk.codePoint.toString()},
  {'name': 'Computer', 'icon': Icons.computer.codePoint.toString()},
  {'name': 'Printer', 'icon': Icons.print.codePoint.toString()},
  {'name': 'Monitor', 'icon': Icons.monitor.codePoint.toString()},
  {'name': 'Scanner', 'icon': Icons.scanner.codePoint.toString()},

  // Laundry Room Devices
  {'name': 'Washer', 'icon': Icons.local_laundry_service.codePoint.toString()},
  {'name': 'Dryer', 'icon': Icons.dry.codePoint.toString()},
  {'name': 'Iron', 'icon': Icons.iron.codePoint.toString()},
  {'name': 'Dehumidifier', 'icon': Icons.water_drop.codePoint.toString()},

  // General/Other Devices
  {'name': 'Security Camera', 'icon': Icons.videocam.codePoint.toString()},
  {'name': 'Smart Lock', 'icon': Icons.lock.codePoint.toString()},
  {'name': 'Motion Sensor', 'icon': Icons.sensors.codePoint.toString()},
  {'name': 'Smart Doorbell', 'icon': Icons.doorbell.codePoint.toString()},
  {'name': 'Thermostat', 'icon': Icons.thermostat.codePoint.toString()},
  {'name': 'WiFi Router', 'icon': Icons.router.codePoint.toString()},
  {'name': 'Smart Switch', 'icon': Icons.toggle_on.codePoint.toString()},
  {'name': 'Smart Plug', 'icon': Icons.power.codePoint.toString()},

  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Device Name',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Device Type',
            ),
            value: _selectedIcon,
            items: _availableIcons.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['icon'],
                child: Row(
                  children: [
                    Icon(IconData(
                      int.parse(item['icon']),
                      fontFamily: 'MaterialIcons',
                    )),
                    const SizedBox(width: 8),
                    Text(item['name']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIcon = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _selectedIcon != null) {
              widget.onAdd(_nameController.text, _selectedIcon!);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}