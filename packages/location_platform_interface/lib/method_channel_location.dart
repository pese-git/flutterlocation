import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:location_platform_interface/messages.pigeon.dart';

///
class MethodChannelLocation extends LocationPlatform {
  ///
  factory MethodChannelLocation() {
    if (_instance == null) {
      const eventChannel = EventChannel('lyokone/location_stream');
      _instance = MethodChannelLocation.private(eventChannel);
    }
    return _instance!;
  }

  /// This constructor is only used for testing and shouldn't be accessed by
  /// users of the plugin. It may break or change at any time.
  @visibleForTesting
  MethodChannelLocation.private(this._eventChannel);

  static MethodChannelLocation? _instance;

  final _api = LocationHostApi();
  late final EventChannel _eventChannel;

  @override
  Future<LocationData?> getLocation({LocationSettings? settings}) {
    return _api.getLocation(settings);
  }

  /// Current opened stream of location
  Stream<LocationData>? _onLocationChanged;

  @override
  Stream<LocationData?> get onLocationChanged {
    return _onLocationChanged ??=
        _eventChannel.receiveBroadcastStream().map<LocationData>(
              (dynamic event) => LocationData.decode(event as Object),
            );
  }

  @override
  Future<bool?> setLocationSettings(LocationSettings settings) {
    return _api.setLocationSettings(settings);
  }

  @override
  Future<PermissionStatus?> getPermissionStatus() async {
    final permission = await _api.getPermissionStatus();
    switch (permission) {
      case 0:
        return PermissionStatus.granted;
      case 1:
        return PermissionStatus.grantedLimited;
      case 2:
        return PermissionStatus.denied;
      case 3:
        return PermissionStatus.deniedForever;
      default:
        throw Exception('Unknown permission status: $permission');
    }
  }
}
