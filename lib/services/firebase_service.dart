// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Room Operations
  Stream<List<Room>> getRooms() {
    return _firestore.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Room.fromMap(data);
      }).toList();
    });
  }

  Future<void> addRoom(Room room) async {
    try {
      await _firestore.collection('rooms').doc(room.id).set(room.toMap());
    } catch (e) {
      print('Error adding room: $e');
      rethrow;
    }
  }

  Future<void> initializeDefaultRooms() async {
    try {
      final defaultRooms = [
        Room(
          id: 'master_bedroom',
          name: 'Master Bedroom',
          image: 'assets/master_bedroom.jpg',
        ),
        Room(
          id: 'living_room',
          name: 'Living Room',
          image: 'assets/living_room.jpg',
        ),
        Room(
          id: 'kitchen',
          name: 'Kitchen',
          image: 'assets/kitchen.jpg',
        ),
        Room(
          id: 'laundry',
          name: 'Laundry',
          image: 'assets/laundry.jpg',
        ),
      ];

      for (final room in defaultRooms) {
        await addRoom(room);
      }
    } catch (e) {
      print('Error initializing default rooms: $e');
      rethrow;
    }
  }

  // Device Operations
  Stream<List<Device>> getDevicesForRoom(String roomId) {
    return _firestore
        .collection('devices')
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Device.fromMap(data);
      }).toList();
    });
  }

  Future<void> addDevice(Device device) async {
    try {
      await _firestore.collection('devices').doc(device.id).set(device.toMap());
    } catch (e) {
      print('Error adding device: $e');
      rethrow;
    }
  }

  Future<void> toggleDevice(String deviceId, bool isActive) async {
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'isActive': isActive,
      });
    } catch (e) {
      print('Error toggling device: $e');
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      await _firestore.collection('devices').doc(deviceId).delete();
    } catch (e) {
      print('Error deleting device: $e');
      rethrow;
    }
  }

  // Schedule Operations
  Stream<List<Schedule>> getSchedulesForDevice(String deviceId) {
    return _firestore
        .collection('schedules')
        .where('deviceId', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Schedule.fromMap(data);
      }).toList();
    });
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _firestore
          .collection('schedules')
          .doc(schedule.id)
          .set(schedule.toMap());
    } catch (e) {
      print('Error adding schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).delete();
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }

  
    final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

}