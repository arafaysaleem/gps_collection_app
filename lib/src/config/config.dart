import 'package:flutter/foundation.dart';

/// A utility class that holds constants for exposing loaded
/// dart environment variables.
/// This class has no constructor and all variables are `static`.
@immutable
class Config {
  const Config._();

  /// The client key for sentry SDK. The DSN tells the SDK where to
  /// send the events to.
  /// 
  /// It is supplied at the time of building the apk or running the app:
  /// ```
  /// flutter build apk --debug --dart-define=SENTRY_DSN=www.some_url.com
  /// ```
  /// OR
  /// ```
  /// flutter run --dart-define=SENTRY_DSN=www.some_url.com
  /// ```
  static const sentryDSN = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: 'https://some-number.ingest.sentry.io/number',
  );
}
