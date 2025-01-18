// lib/pages/notification_page.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  Widget _buildNotificationCard(BuildContext context, AppNotification notification) {
    final FirebaseService firebaseService = FirebaseService();
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case 'room_added':
        iconData = Icons.add_home;
        iconColor = Colors.green;
        break;
      case 'room_deleted':
        iconData = Icons.delete;
        iconColor = Colors.red;
        break;
      case 'device_added':
        iconData = Icons.devices;
        iconColor = Colors.blue;
        break;
      case 'device_deleted':
        iconData = Icons.device_unknown;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.purple;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red[400],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.close,  // Changed from delete_outline to close
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        firebaseService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: notification.isRead ? 1 : 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(notification.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Read/Unread toggle
                IconButton(
                  icon: Icon(
                    notification.isRead ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    if (notification.isRead) {
                      // Create a new notification with isRead = false
                      final updatedNotification = AppNotification(
                        id: notification.id,
                        title: notification.title,
                        message: notification.message,
                        timestamp: notification.timestamp,
                        type: notification.type,
                        isRead: false,
                      );
                      firebaseService.addNotification(updatedNotification);
                    } else {
                      firebaseService.markNotificationAsRead(notification.id);
                    }
                  },
                ),
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    firebaseService.deleteNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.purple[400],
        actions: [
          StreamBuilder<List<AppNotification>>(
            stream: firebaseService.getNotifications(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'mark_all_read') {
                    for (var notification in snapshot.data!) {
                      if (!notification.isRead) {
                        await firebaseService.markNotificationAsRead(notification.id);
                      }
                    }
                  } else if (value == 'mark_all_unread') {
                    for (var notification in snapshot.data!) {
                      if (notification.isRead) {
                        final updatedNotification = AppNotification(
                          id: notification.id,
                          title: notification.title,
                          message: notification.message,
                          timestamp: notification.timestamp,
                          type: notification.type,
                          isRead: false,
                        );
                        await firebaseService.addNotification(updatedNotification);
                      }
                    }
                  } else if (value == 'clear_all') {
                    for (var notification in snapshot.data!) {
                      await firebaseService.deleteNotification(notification.id);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('Mark all as read'),
                  ),
                  const PopupMenuItem(
                    value: 'mark_all_unread',
                    child: Text('Mark all as unread'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear all'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: firebaseService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final notification = snapshot.data![index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }
}