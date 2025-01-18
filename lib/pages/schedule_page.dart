import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/scheduler_service.dart';

class SchedulePage extends StatefulWidget {
  final Device device;

  const SchedulePage({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _hasEndTime = true;
  late Stream<Device> _deviceStream;
  Device? _currentDevice;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeDeviceData();
    _setupDeviceStream();
  }

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

  void _initializeDeviceData() {
    _startTime = widget.device.scheduleStart != null
        ? TimeOfDay.fromDateTime(widget.device.scheduleStart!)
        : null;
    _endTime = widget.device.scheduleEnd != null
        ? TimeOfDay.fromDateTime(widget.device.scheduleEnd!)
        : null;
    _hasEndTime = widget.device.scheduleEnd != null;
  }

  void _setupDeviceStream() {
    _deviceStream = _firebaseService.getDeviceStream(widget.device.id);
    _deviceStream.listen((device) {
      if (mounted) {
        setState(() {
          _currentDevice = device;
        });
      }
    });
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (!_hasEndTime) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final startDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = _hasEndTime && _endTime != null
          ? DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              _endTime!.hour,
              _endTime!.minute,
            )
          : null;

      await _firebaseService.updateDeviceSchedule(
        widget.device.id,
        startDateTime,
        endDateTime,
      );

      // Create notification for schedule update
      final scheduleDetails = _hasEndTime && _endTime != null
          ? '${_formatTimeOfDay(_startTime)} to ${_formatTimeOfDay(_endTime)}'
          : 'starts at ${_formatTimeOfDay(_startTime)}';
      
      await _createNotification(
        'Schedule Set',
        '${widget.device.name} scheduled: $scheduleDetails',
        'schedule_set'
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate schedule was set
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearSchedule() async {
    try {
      await _firebaseService.updateDeviceSchedule(
        widget.device.id,
        null,
        null,
      );

      // Create notification for schedule clearing
      await _createNotification(
        'Schedule Cleared',
        'Schedule for ${widget.device.name} has been cleared',
        'schedule_cleared'
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Not set';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule ${widget.device.name}'),
        backgroundColor: Colors.purple[400],
      ),
      body: StreamBuilder<Device>(
        stream: _deviceStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final device = snapshot.data ?? widget.device;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              IconData(
                                int.parse(device.icon),
                                fontFamily: 'MaterialIcons',
                              ),
                              size: 24,
                              color: Colors.purple[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: device.isActive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              device.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Set Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Start Time'),
                          subtitle: Text(_formatTimeOfDay(_startTime)),
                          trailing: const Icon(Icons.access_time),
                          onTap: _selectStartTime,
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Set End Time'),
                          value: _hasEndTime,
                          onChanged: (value) {
                            setState(() {
                              _hasEndTime = value;
                              if (!value) {
                                _endTime = null;
                              }
                            });
                          },
                        ),
                        if (_hasEndTime) ...[
                          const Divider(),
                          ListTile(
                            title: const Text('End Time'),
                            subtitle: Text(_formatTimeOfDay(_endTime)),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectEndTime,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _clearSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Clear Schedule',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Save Schedule',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}