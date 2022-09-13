import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../config/config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  // These key names have to match the ones on the Firebase Console
  static const _primaryEmail = 'primary_email';
  static const _ccEmail = 'cc_email';

  String get primaryEmail => _remoteConfig.getString(_primaryEmail);
  String get ccEmail => _remoteConfig.getString(_ccEmail);

  static const _defaults = <String, dynamic>{
    _primaryEmail: Config.primaryEmail,
    _ccEmail: Config.ccEmail,
  };

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval:
            kDebugMode ? const Duration(minutes: 1) : const Duration(hours: 14),
      ),
    );
    await _remoteConfig.setDefaults(_defaults);
    await _fetchAndActivate();
  }

  static Future<void> _fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      if (activated) {
        debugPrint(
          'New parameters already applied. Using previously activated values',
        );
      }
    } catch (e) {
      debugPrint('Unable to fetch remote config, default value will be used');
    }
  }

  Future<void> fetchAndActivate() async => _fetchAndActivate();
}
