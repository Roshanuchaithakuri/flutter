// lib/models/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String roomId;
  final String icon;
  bool isActive;
  DateTime? scheduleStart;
  DateTime? scheduleEnd;

  Device({
    required this.id,
    required this.name,
    required this.roomId,
    required this.icon,
    this.isActive = false,
    this.scheduleStart,
    this.scheduleEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomId': roomId,
      'icon': icon,
      'isActive': isActive,
      'scheduleStart': scheduleStart != null ? Timestamp.fromDate(scheduleStart!) : null,
      'scheduleEnd': scheduleEnd != null ? Timestamp.fromDate(scheduleEnd!) : null,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      roomId: map['roomId'] ?? '',
      icon: map['icon'] ?? '',
      isActive: map['isActive'] ?? false,
      scheduleStart: map['scheduleStart'] != null ? (map['scheduleStart'] as Timestamp).toDate() : null,
      scheduleEnd: map['scheduleEnd'] != null ? (map['scheduleEnd'] as Timestamp).toDate() : null,
    );
  }
}

class Room {
  final String id;
  final String name;
  final String image;
  final int deviceCount;

  Room({
    required this.id,
    required this.name,
    required this.image,
    this.deviceCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'deviceCount': deviceCount,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      deviceCount: map['deviceCount'] ?? 0,
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Room operations
  Future<void> addRoom(Room room) async {
    await _firestore.collection('rooms').doc(room.id).set(room.toMap());
  }

  Stream<List<Room>> getRooms() {
    return _firestore.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Room.fromMap(doc.data())).toList();
    });
  }

  // Device operations
  Future<void> addDevice(Device device) async {
    await _firestore.collection('devices').doc(device.id).set(device.toMap());
    // Update room device count
    await _firestore.collection('rooms').doc(device.roomId).update({
      'deviceCount': FieldValue.increment(1),
    });
  }

  Stream<List<Device>> getDevicesForRoom(String roomId) {
    return _firestore
        .collection('devices')
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Device.fromMap(doc.data())).toList();
    });
  }

  Future<void> toggleDevice(String deviceId, bool isActive) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'isActive': isActive,
    });
  }

  Future<void> updateDeviceSchedule(String deviceId, DateTime? startTime, DateTime? endTime) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'scheduleStart': startTime != null ? Timestamp.fromDate(startTime) : null,
      'scheduleEnd': endTime != null ? Timestamp.fromDate(endTime) : null,
    });
  }

  Future<void> deleteDevice(Device device) async {
    await _firestore.collection('devices').doc(device.id).delete();
    await _firestore.collection('rooms').doc(device.roomId).update({
      'deviceCount': FieldValue.increment(-1),
    });
  }


  Future<void> deleteRoom(String roomId) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    
    final devicesSnapshot = await _firestore
        .collection('devices')
        .where('roomId', isEqualTo: roomId)
        .get();

    final batch = _firestore.batch();
    batch.delete(roomRef);

    for (var doc in devicesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
}

Stream<Device> getDeviceStream(String deviceId) {
  return FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .snapshots()
      .map((snapshot) => Device.fromMap(snapshot.data()!));
}

}