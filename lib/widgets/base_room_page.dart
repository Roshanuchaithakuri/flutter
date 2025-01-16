// // lib/widgets/base_room_page.dart
// import 'package:flutter/material.dart';
// import '../models/models.dart';
// import '../services/firebase_service.dart';
// import 'schedule_bottom_sheet.dart';

// class BaseRoomPage extends StatefulWidget {
//   final Room room;
//   final FirebaseService firebaseService;

//   const BaseRoomPage({
//     Key? key,
//     required this.room,
//     required this.firebaseService,
//   }) : super(key: key);

//   @override
//   State<BaseRoomPage> createState() => _BaseRoomPageState();
// }

// class _BaseRoomPageState extends State<BaseRoomPage> {
//   Future<void> _showAddDeviceDialog() async {
//     final nameController = TextEditingController();
//     final iconController = TextEditingController();

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add New Device'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Device Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: iconController,
//               decoration: const InputDecoration(
//                 labelText: 'Icon Name (e.g., lightbulb_outline)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               if (nameController.text.isNotEmpty) {
//                 final device = Device(
//                   id: 'device_${DateTime.now().millisecondsSinceEpoch}',
//                   name: nameController.text,
//                   roomId: widget.room.id,
//                   icon: iconController.text.isNotEmpty
//                       ? iconController.text
//                       : 'devices',
//                 );
//                 await widget.firebaseService.addDevice(device);
//                 if (mounted) Navigator.pop(context);
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showScheduleDialog(Device device) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: ScheduleBottomSheet(
//           device: device,
//           firebaseService: widget.firebaseService,
//         ),
//       ),
//     );
//   }

//   IconData _getIconData(String iconName) {
//     switch (iconName) {
//       case 'lightbulb_outline':
//         return Icons.lightbulb_outline;
//       case 'ac_unit':
//         return Icons.ac_unit;
//       case 'tv':
//         return Icons.tv;
//       case 'wifi':
//         return Icons.wifi;
//       case 'local_fire_department':
//         return Icons.local_fire_department;
//       case 'microwave':
//         return Icons.microwave;
//       case 'local_laundry_service':
//         return Icons.local_laundry_service;
//       case 'dry':
//         return Icons.dry;
//       case 'wind_power':
//         return Icons.wind_power;
//       default:
//         return Icons.devices;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.room.name),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: _showAddDeviceDialog,
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<Device>>(
//         stream: widget.firebaseService.getDevicesForRoom(widget.room.id),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           }

//           if (!snapshot.hasData) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           final devices = snapshot.data!;

//           if (devices.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('No devices added yet'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _showAddDeviceDialog,
//                     child: const Text('Add Device'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: devices.length,
//             itemBuilder: (context, index) {
//               final device = devices[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   leading: Icon(_getIconData(device.icon)),
//                   title: Text(device.name),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Switch(
//                         value: device.isActive,
//                         onChanged: (value) async {
//                           await widget.firebaseService.toggleDevice(
//                             device.id,
//                             value,
//                           );
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.schedule),
//                         onPressed: () => _showScheduleDialog(device),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () async {
//                           await widget.firebaseService.deleteDevice(device.id);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // a


// lib/widgets/base_room_page.dart
import 'package:flutter/material.dart';
import '../widgets/circle_button.dart';
import '../pages/home_page.dart';

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

class BaseRoomPage extends StatelessWidget {
  final String title;
  final List<DeviceButton> devices;
  final Function(int, bool) onDeviceToggle;

  const BaseRoomPage({
    super.key,
    required this.title,
    required this.devices,
    required this.onDeviceToggle,
  });

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(title),
            _buildDevicesGrid(),
            const Spacer(),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 40,
                height: 40,
              ),
              Row(
                children: const [
                  CircleButton(icon: Icons.settings),
                  SizedBox(width: 8),
                  CircleButton(icon: Icons.notifications_outlined),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade200, Colors.pink.shade100],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return _buildDeviceCard(index);
        },
      ),
    );
  }

  Widget _buildDeviceCard(int index) {
    final device = devices[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            device.icon,
            size: 32,
            color: Colors.indigo,
          ),
          const SizedBox(height: 8),
          Text(
            device.name,
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Switch(
            value: device.isActive,
            onChanged: (value) => onDeviceToggle(index, value),
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => _navigateToHome(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_outlined, color: Colors.grey),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mic_outlined, color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}