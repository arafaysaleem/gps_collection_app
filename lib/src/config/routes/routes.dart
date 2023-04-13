// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

// Helpers
import '../../helpers/typedefs.dart';

// Features
import '../../features/app_startup/startup_widget_builder.dart';
import '../../features/planned_sampling/screens/planned_sampling_screen.dart';
import '../../features/home/screens/home_screen.dart';

/// A utility class that holds screen names for named navigation.
/// This class has no constructor and all variables are `static`.
@immutable
class Routes {
  const Routes._();

  /// The route to be loaded when app launches
  static const String initialRoute = StartupWidgetBuilderRoute;

  /// The route to be loaded in case of unrecognized route name
  static const String fallbackRoute = NotFoundScreenRoute;

  // The name for the auth widget screen
  static const String StartupWidgetBuilderRoute = '/startup-widget-builder';

  /// The name of the route for home dashboard screen
  static const String HomeScreenRoute = '/home-screen';

  /// The name of the route for data import screen
  static const String PlannedSamplingRoute = '/planned-sampling-screen';

  /// The name of the route for farmer setup screen
  static const String AddNewFarmerRoute = '/farmer-setup-screen';

  /// The name of the route for unrecognized route screen
  static const String NotFoundScreenRoute = '/route-not-found-screen';

  static final Map<String, RouteBuilder> _routesMap = {
    StartupWidgetBuilderRoute: (_) => const StartupWidgetBuilder(),
    HomeScreenRoute: (_) => const HomeScreen(),
    PlannedSamplingRoute: (_) => const PlannedSamplingScreen(),
    AddNewFarmerRoute: (_) => const SizedBox.shrink(),
    NotFoundScreenRoute: (_) => const SizedBox.shrink(),
  };

  static RouteBuilder getRoute(String? routeName) {
    return routeExists(routeName)
        ? _routesMap[routeName]!
        : _routesMap[Routes.NotFoundScreenRoute]!;
  }

  static bool routeExists(String? routeName) {
    return _routesMap.containsKey(routeName);
  }
}
