// lib/services/scheduler_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class SchedulerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  
  // Define Sydney timezone offset
  static const int sydneyOffset = 11;  // GMT+11

  DateTime getSydneyTime() {
    final now = DateTime.now().toUtc();
    return now.add(Duration(hours: sydneyOffset));
  }
  
  void startScheduler() {
    // Check devices every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkScheduledDevices();
    });
  }

  void stopScheduler() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkScheduledDevices() async {
    try {
      final devicesSnapshot = await _firestore.collection('devices').get();
      final sydneyNow = getSydneyTime();

      print('Checking devices at Sydney time: ${DateFormat('HH:mm').format(sydneyNow)}');

      for (var doc in devicesSnapshot.docs) {
        final device = Device.fromMap(doc.data());
        
        if (device.scheduleStart != null && device.scheduleEnd != null) {
          // Convert schedule times to Sydney timezone if they aren't already
          final startTime = _convertToSydneyTime(device.scheduleStart!);
          final endTime = _convertToSydneyTime(device.scheduleEnd!);

          // Check if current time is within schedule
          if (_isWithinSchedule(sydneyNow, startTime, endTime)) {
            if (!device.isActive) {
              print('Turning ON device ${device.name} at ${DateFormat('HH:mm').format(sydneyNow)}');
              await _firestore.collection('devices').doc(device.id).update({
                'isActive': true
              });
            }
          } else {
            if (device.isActive) {
              print('Turning OFF device ${device.name} at ${DateFormat('HH:mm').format(sydneyNow)}');
              await _firestore.collection('devices').doc(device.id).update({
                'isActive': false
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error checking scheduled devices: $e');
    }
  }

  DateTime _convertToSydneyTime(DateTime time) {
    // If the time is not in UTC, convert it to UTC first
    final utcTime = time.toUtc();
    // Then convert to Sydney time
    return utcTime.add(Duration(hours: sydneyOffset));
  }

  bool _isWithinSchedule(DateTime current, DateTime start, DateTime end) {
    // Extract hours and minutes for comparison
    int currentMinutes = current.hour * 60 + current.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // Normal range (e.g., 9:00 to 17:00)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight range (e.g., 22:00 to 06:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  // Helper method to format time for logging
  String _formatTimeForLog(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}