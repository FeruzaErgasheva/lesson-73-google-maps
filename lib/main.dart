import 'package:flutter/material.dart';
import 'package:lesson72_location/screens/home_screen.dart';
import 'package:lesson72_location/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // PermissionStatus cameraPermission = await Permission.camera.status;
  // PermissionStatus locationPermission = await Permission.location.status;

  // if (cameraPermission != PermissionStatus.granted) {
  //   cameraPermission = await Permission.camera.request();
  // }

  // if (locationPermission != PermissionStatus.granted) {
  //   locationPermission = await Permission.location.request();
  // }

  // print(cameraPermission);
  // print(locationPermission);

  // if (!(await Permission.camera.request().isGranted) ||
  //     !(await Permission.location.request().isGranted)) {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.location,
  //     Permission.camera,
  //   ].request();

  //   print(statuses);
  // }

  await LocationService.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
