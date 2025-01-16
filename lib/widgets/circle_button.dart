// lib/widgets/circle_button.dart
import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CircleButton({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed ?? () {},
        color: Colors.grey[700],
      ),
    );
  }
}