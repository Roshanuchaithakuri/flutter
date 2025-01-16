import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final Device device;
  final FirebaseService firebaseService;

  const ScheduleBottomSheet({
    Key? key,
    required this.device,
    required this.firebaseService,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(
      hour: (TimeOfDay.now().hour + 1) % 24,
      minute: TimeOfDay.now().minute,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    final DateTime startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final DateTime endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Validate time selection
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final schedule = Schedule(
        id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
        deviceId: widget.device.id,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      await widget.firebaseService.addSchedule(schedule);
      if (mounted) {
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule ${widget.device.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            trailing: TextButton(
              onPressed: _selectDate,
              child: Text(
                DateFormat('MMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Start Time'),
            trailing: TextButton(
              onPressed: () => _selectTime(true),
              child: Text(
                _startTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_filled),
            title: const Text('End Time'),
            trailing: TextButton(
              onPressed: () => _selectTime(false),
              child: Text(
                _endTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Schedule>>(
            stream: widget.firebaseService.getSchedulesForDevice(widget.device.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final schedules = snapshot.data!;
              if (schedules.isEmpty) {
                return const Center(
                  child: Text(
                    'No schedules set',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Existing Schedules',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...schedules.map((schedule) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${DateFormat('HH:mm').format(schedule.startTime)} - '
                        '${DateFormat('HH:mm').format(schedule.endTime)}',
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(schedule.startTime),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          try {
                            await widget.firebaseService
                                .deleteSchedule(schedule.id);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting schedule: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  )),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Schedule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}