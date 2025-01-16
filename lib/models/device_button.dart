

// lib/models/device_button.dart
import 'package:flutter/material.dart';

class DeviceButton {
  final String name;
  final IconData icon;
  bool isActive;

  DeviceButton({
    required this.name,
    required this.icon,
    this.isActive = false,
  });
}