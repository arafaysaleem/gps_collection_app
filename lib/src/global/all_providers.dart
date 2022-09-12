import 'package:flutter_riverpod/flutter_riverpod.dart';

// Services
import '../core/local/key_value_storage_service.dart';
import '../core/remote/remote_config_service.dart';

final keyValueStorageServiceProvider = Provider<KeyValueStorageService>(
  (ref) => KeyValueStorageService(),
);

final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => RemoteConfigService(),
);
