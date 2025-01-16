// lib/models/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String roomId;
  final String icon;
  bool isActive;

  Device({
    required this.id,
    required this.name,
    required this.roomId,
    required this.icon,
    this.isActive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomId': roomId,
      'icon': icon,
      'isActive': isActive,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      roomId: map['roomId'] ?? '',
      icon: map['icon'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }
}

class Room {
  final String id;
  final String name;
  final String image;
  final List<Device> devices;

  Room({
    required this.id,
    required this.name,
    required this.image,
    this.devices = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
    );
  }
}

class Schedule {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String deviceId;

  Schedule({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'deviceId': deviceId,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      deviceId: map['deviceId'] ?? '',
    );
  }
}