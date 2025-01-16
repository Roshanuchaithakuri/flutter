import 'package:flutter/material.dart';
import '../models/models.dart';
import 'room_page.dart';

class LaundryPage extends RoomPage {
  LaundryPage({
    Key? key,
    required Room room,
  }) : super(
          key: key,
          room: room,
          defaultDevices: [
            Device(
              id: 'ld_washer_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Washing Machine',
              roomId: room.id,
              icon: 'local_laundry_service',
            ),
            Device(
              id: 'ld_dryer_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Dryer',
              roomId: room.id,
              icon: 'dry',
            ),
            Device(
              id: 'ld_lights_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Lights',
              roomId: room.id,
              icon: 'lightbulb_outline',
            ),
            Device(
              id: 'ld_fan_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Exhaust Fan',
              roomId: room.id,
              icon: 'wind_power',
            ),
          ],
        );

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends RoomPageState<LaundryPage> {}