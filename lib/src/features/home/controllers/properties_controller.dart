import 'dart:collection';

import 'package:hooks_riverpod/hooks_riverpod.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Providers
import '../../../global/all_providers.dart';
import 'paddocks_controller.dart';

// Models
import '../models/paddock_model.codegen.dart';

final currentPropertyProvider = StateProvider<String?>((ref) => null);

final propertiesController = Provider<PropertiesController>((ref) {
  final keyValueService = ref.watch(keyValueStorageServiceProvider);
  return PropertiesController(ref, keyValueService);
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
    _properties = properties;

    final property = _keyValueStorageService.getCurrentProperty();
    _ref.read(currentPropertyProvider.notifier).state =
        property ?? (_properties.isNotEmpty ? _properties.first : null);
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

  void setCurrentProperty(String property) {
    _ref.read(currentPropertyProvider.notifier).state = property;
    _ref.read(paddocksController.notifier).setCurrentPaddock(null);
  }
}
