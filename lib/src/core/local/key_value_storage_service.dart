// Services
// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:convert';

// Features
import '../../features/sampling_modes/enums/sampling_mode.dart';
import '../../features/home/models/coordinate_model.codegen.dart';
import '../../features/home/models/farmer_model.codegen.dart';
import '../../features/home/models/paddock_model.codegen.dart';

// Helpers
import '../../helpers/typedefs.dart';

// Services
import 'key_value_storage_base.dart';

/// A service class for providing methods to store and retrieve key-value data
/// from common or secure storage.
class KeyValueStorageService {
  /// The name of paddocks data key
  static const _paddocksKey = 'paddocksKey';

  /// The name of properties data key
  static const _propertiesKey = 'propertiesKey';

  /// The name of farmer model key
  static const _farmerKey = 'farmerKey';

  /// The name of current property key
  static const _propertyKey = 'propertyKey';

  /// The name of current paddock key
  static const _paddockCodeKey = 'paddockCodeKey';

  /// The name of current tool key
  static const _toolKey = 'toolKey';

  /// The name of is current sampling key
  static const _currentSamplingKey = 'currentSamplingKey';

  /// The name of the key for paddock's coordinates
  String _getPaddockCoordinateKey(String paddockCode) => '$paddockCode-COORDS';

  /// The name of the key for paddock's note
  String _getPaddockNoteKey(String paddockCode) => '$paddockCode-NOTE';

  /// Instance of key-value storage base class
  final _keyValueStorage = KeyValueStorageBase();

  /// Returns the list of paddocks
  List<PaddockModel> getPaddocks() {
    final paddocks = _keyValueStorage.getCommon<List<String>>(_paddocksKey);
    return paddocks
            ?.map((e) => PaddockModel.fromJson(jsonDecode(e) as JSON))
            .toList() ??
        [];
  }

  /// Sets the coordinates data for this paddock code to this value.
  Future<bool> setPaddockCoordinates(
    List<CoordinateModel> coordinates,
    String paddockCode,
  ) async {
    final paddocksJson =
        coordinates.map((e) => jsonEncode(e.toJson())).toList();
    return _keyValueStorage.setCommon<List<String>>(
      _getPaddockCoordinateKey(paddockCode),
      paddocksJson,
    );
  }

  /// Returns the list of coordinates
  List<CoordinateModel>? getPaddockCoordinates(String paddockCode) {
    final coordinates = _keyValueStorage.getCommon<List<String>>(
      _getPaddockCoordinateKey(paddockCode),
    );
    if (coordinates == null) return null;
    return coordinates
        .map((e) => CoordinateModel.fromJson(jsonDecode(e) as JSON))
        .toList();
  }

  /// Sets the paddocks data to this value.
  Future<bool> setPaddocks(List<PaddockModel> paddocks) async {
    final paddocksJson = paddocks.map((e) => jsonEncode(e.toJson())).toList();
    return _keyValueStorage.setCommon<List<String>>(_paddocksKey, paddocksJson);
  }

  /// Returns the list of properties
  Set<String> getProperties() {
    final properties = _keyValueStorage.getCommon<List<String>>(_propertiesKey);
    return properties?.toSet() ?? {};
  }

  /// Sets the paddocks data to this value.
  Future<bool> setProperties(Set<String> properties) async {
    return _keyValueStorage.setCommon<List<String>>(
      _propertiesKey,
      properties.toList(),
    );
  }

  /// Returns the farmer data
  FarmerModel? getFarmer() {
    final farmer = _keyValueStorage.getCommon<String>(_farmerKey);
    if (farmer == null) return null;
    return FarmerModel.fromJson(jsonDecode(farmer) as JSON);
  }

  /// Sets the farmer data to this value.
  Future<bool> setFarmer(FarmerModel farmer) async {
    return _keyValueStorage.setCommon<String>(
      _farmerKey,
      jsonEncode(farmer.toJson()),
    );
  }

  /// Sets the current property data to this value.
  Future<bool> setCurrentProperty(String property) async {
    return _keyValueStorage.setCommon<String>(_propertyKey, property);
  }

  /// Returns the current property data
  String? getCurrentProperty() {
    final property = _keyValueStorage.getCommon<String>(_propertyKey);
    if (property == null) return null;
    return property;
  }

  /// Returns the current paddock code
  String? getCurrentPaddockCode() {
    final paddockCode = _keyValueStorage.getCommon<String>(_paddockCodeKey);
    if (paddockCode == null) return null;
    return paddockCode;
  }

  /// Sets the current paddock code to this value.
  Future<bool> setCurrentPaddock(String paddockCode) async {
    return _keyValueStorage.setCommon<String>(_paddockCodeKey, paddockCode);
  }

  /// Returns the sampling state
  SamplingMode? getCurrentSamplingState() {
    final sampling = _keyValueStorage.getCommon<String>(_currentSamplingKey);
    if (sampling == null) return null;
    return SamplingMode.values.firstWhere(
      (element) => element.name == sampling,
    );
  }

  /// Sets current sampling state to this value. Even though this method is
  /// asynchronous, we don't care about it's completion which is why we don't
  /// use `await` and let it execute in the background.
  Future<bool> setCurrentSamplingState(
    SamplingMode currentSamplingState,
  ) async {
    return _keyValueStorage.setCommon<String>(
      _currentSamplingKey,
      currentSamplingState.name,
    );
  }

  /// Returns the current tool name
  String? getCurrentTool() {
    final tool = _keyValueStorage.getCommon<String>(_toolKey);
    return tool;
  }

  /// Sets the current tool data to this value. Even though this method is
  /// asynchronous, we don't care about it's completion which is why we don't
  /// use `await` and let it execute in the background.
  void setCurrentTool(String tool) {
    _keyValueStorage.setCommon<String>(_toolKey, tool);
  }

  /// Returns the paddock note
  String? getPaddockNote(String paddockCode) {
    final note = _keyValueStorage.getCommon<String>(
      _getPaddockNoteKey(paddockCode),
    );
    return note;
  }

  /// Sets the current paddock note to this value. Even though this method is
  /// asynchronous, we don't care about it's completion which is why we don't
  /// use `await` and let it execute in the background.
  void setPaddockNote(String note, String paddockCode) {
    _keyValueStorage.setCommon<String>(
      _getPaddockNoteKey(paddockCode),
      note,
    );
  }
  
  Future<bool> resetKeys() async => _keyValueStorage.clearCommon();
}
