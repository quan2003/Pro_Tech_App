// models/device.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String warranty;
  final String purchase;
  final bool active;
  final String platform;
  final String ipAddress;
  final String lastLogin;
  final String deviceType;
  final String deviceModel;

  Device({
    required this.id,
    required this.name,
    required this.warranty,
    required this.purchase,
    required this.active,
    required this.platform,
    required this.ipAddress,
    required this.lastLogin,
    required this.deviceType,
    required this.deviceModel,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['deviceId'] ?? '',
      name: map['deviceName'] ?? 'Unknown Device',
      warranty: map['warrantyDate'] ?? 'Unknown',
      purchase: map['purchaseDate'] ?? 'Unknown',
      active: map['isActive'] ?? false,
      platform: map['platform'] ?? 'Unknown',
      ipAddress: map['ipAddress'] ?? 'Unknown',
      lastLogin: map['lastLoginTime'] != null
          ? (map['lastLoginTime'] as Timestamp).toDate().toString()
          : 'Never',
      deviceType: getDeviceType(map['platform'] ?? ''),
      deviceModel: map['deviceModel'] ?? 'Unknown',
    );
  }

  static String getDeviceType(String platform) {
    platform = platform.toLowerCase();
    if (platform.contains('ios')) return 'iOS';
    if (platform.contains('android')) return 'Android';
    if (platform.contains('web')) return 'Web';
    return 'Unknown';
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': id,
      'deviceName': name,
      'warrantyDate': warranty,
      'purchaseDate': purchase,
      'isActive': active,
      'platform': platform,
      'ipAddress': ipAddress,
      'lastLoginTime': lastLogin,
      'deviceModel': deviceModel,
    };
  }
}
