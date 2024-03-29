import 'dart:convert';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helpers
import '../extensions/datetime_extension.dart';
import 'app_colors.dart';
import 'app_styles.dart';

/// A utility class that holds commonly used functions
/// This class has no constructor and all variables are `static`.
@immutable
class AppUtils {
  const AppUtils._();

  /// A random value generator
  static Random randomizer([int? seed]) => Random(seed);

  /// A utility method to map an integer to a color code
  /// Useful for color coding class erps
  static Color getRandomColor([int? seed, List<Color>? colors]) {
    final rInt = seed != null ? (seed + DateTime.now().minute) : null;
    final thisColors = colors ?? AppColors.primaries;
    return thisColors[randomizer(rInt).nextInt(thisColors.length)];
  }

  /// A utility method to generate a random UUID.
  static String getRandomUuid([String? seed, int length = 5]) {
    final prefix = seed != null ? '$seed-' : '';
    final rInt = seed != null ? utf8.encode(seed).hashCode : null;
    final random = randomizer(rInt);
    return '$prefix${random.nextInt(pow(10, length).toInt())}';
  }

  /// A utility method to convert 0/1 to false/true
  static bool boolFromInt(int i) => i == 1;

  /// A utility method to convert true/false to 1/0
  // ignore: avoid_positional_boolean_parameters
  static int boolToInt(bool b) => b ? 1 : 0;

  /// A utility method to convert DateTime to API
  /// accepted date JSON format
  static String dateToJson(DateTime date) {
    return date.toDateString('yyyy-MM-dd');
  }

  /// A utility method to convert DateTime to API
  /// accepted datetime JSON format
  static String dateTimeToJson(DateTime date) {
    return date.toDateString('yyyy-MM-dd HH:mm:ss');
  }

  /// A utility method to convert JSON 24hr time string
  /// to a [TimeOfDay] object
  static TimeOfDay timeFromJson(String time) {
    final dateTime = DateFormat.Hms().parse(time);
    return TimeOfDay.fromDateTime(dateTime);
  }

  /// A utility method to convert any instance to null
  static T? toNull<T>(Object? _) => null;

  /// A utility method to remove nulls from int list
  static List<int>? removeNulls(List<dynamic>? list) {
    return list?.whereType<int>().toList();
  }

  /// Helper method to show toast message
  static void showFlushBar({
    required BuildContext context,
    required String message,
    IconData? icon = Icons.error_rounded,
    bool blockBackgroundInteraction = false,
    double? iconSize = 26,
    Color? iconColor = Colors.redAccent,
  }) {
    Flushbar<void>(
      message: message,
      messageSize: 15,
      messageColor: AppColors.textWhite80Color,
      animationDuration: Durations.slow,
      blockBackgroundInteraction: blockBackgroundInteraction,
      borderRadius: Corners.rounded(9),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 85),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      backgroundColor: const Color.fromARGB(218, 48, 48, 48),
      boxShadows: Shadows.universal,
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      shouldIconPulse: false,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      duration: const Duration(milliseconds: 1300),
    ).show(context);
  }
}

/// A utility class that holds all the timings used throughout
/// the entire app by things such as animations, tickers etc.
///
/// This class has no constructor and all variables are `static`.
@immutable
class Durations {
  const Durations._();

  static const fastest = Duration(milliseconds: 150);
  static const fast = Duration(milliseconds: 250);
  static const normal = Duration(milliseconds: 300);
  static const medium = Duration(milliseconds: 500);
  static const slow = Duration(milliseconds: 700);
  static const slower = Duration(milliseconds: 1000);
}
