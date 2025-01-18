// lib/pages/notification_page.dart
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.purple[400],
      ),
      body: ListView.builder(
        itemCount: 0,  // Replace with actual notifications count
        itemBuilder: (context, index) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('No notifications yet'),
              subtitle: Text('You\'ll see your notifications here'),
            ),
          );
        },
      ),
    );
  }
}