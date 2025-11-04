import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestLocationPermissions() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }
}
