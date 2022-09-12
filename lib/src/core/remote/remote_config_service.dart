import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static const _primaryEmail = 'primary_email';
  static const _ccEmail = 'cc_email';

  String get primaryEmail => _remoteConfig.getString(_primaryEmail);
  String get ccEmail => _remoteConfig.getString(_ccEmail);

  static const _defaults = <String, dynamic>{
    _primaryEmail: 'nutrientmapping@dpird.wa.gov.au',
    _ccEmail: 'peta.richards@dpird.wa.gov.au',
  };

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(hours: kDebugMode ? 5 : 14),
      ),
    );
    await _remoteConfig.setDefaults(_defaults);
    await _fetchAndActivate();
  }

  static Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Unable to fetch remote config, default value will be used');
    }
  }

  Future<void> fetchAndActivate() async => _fetchAndActivate();
}
