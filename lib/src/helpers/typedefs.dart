import 'package:flutter/material.dart';

typedef JSON = Map<String, dynamic>;
typedef QueryParams = Map<String, String>;
typedef SnapshotBuilder<T> = T Function(JSON? data, String documentID);
typedef Sorter<T> = int Function(T lhs, T rhs)?;
typedef RouteBuilder = Widget Function(BuildContext);
typedef ItemBuilder<T> = Widget Function(BuildContext, T);
