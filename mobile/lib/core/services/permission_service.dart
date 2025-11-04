import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }
}
