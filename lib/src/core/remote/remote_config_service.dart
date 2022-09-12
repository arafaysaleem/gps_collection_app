// ignore_for_file: prefer_constructors_over_static_methods

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  String get primaryEmail => _remoteConfig.getString(_primaryEmail);
  String get ccEmail => _remoteConfig.getString(_ccEmail);

  RemoteConfigService._();

  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const _primaryEmail = 'primary_email';
  static const _ccEmail = 'cc_email';

  static RemoteConfigService? _instance;

  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  static Future<void> init() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Unable to fetch remote config, default value will be used');
    }
  }
}
