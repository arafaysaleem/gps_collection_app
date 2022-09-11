import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Providers
import '../../../global/all_providers.dart';

// Models
import '../models/paddock_model.codegen.dart';

final currentPropertyProvider = StateProvider<String?>((ref) => null);

final propertiesController = Provider<PropertiesController>((ref) {
  final _keyValueService = ref.watch(keyValueStorageServiceProvider);
  return PropertiesController(ref, _keyValueService);
});

class PropertiesController {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  late final Set<String> _properties;

  PropertiesController(this._ref, this._keyValueStorageService);

  Future<void> importPropertiesData(List<PaddockModel> paddocks) async {
    _properties = paddocks.map((element) => element.propertyId).toSet();
    await savePropertiesInCache(_properties);
    _ref.read(currentPropertyProvider.notifier).state = _properties.first;
  }

  void loadPropertiesFromCache() {
    final properties = _keyValueStorageService.getProperties();
    if (properties == null) {
      debugPrint('Properties not loaded from cache');
      throw Exception('Properties not loaded from cache');
    }
    _properties = properties;

    final property = _keyValueStorageService.getCurrentProperty();
    _ref.read(currentPropertyProvider.notifier).state =
        property ?? _properties.first;
  }

  UnmodifiableListView<String> getAllProperties() {
    return UnmodifiableListView(_properties);
  }

  Future<bool> saveCurrentPropertyInCache(String property) async {
    return _keyValueStorageService.setCurrentProperty(property);
  }

  Future<bool> savePropertiesInCache(Set<String> properties) async {
    return _keyValueStorageService.setProperties(properties);
  }
}
