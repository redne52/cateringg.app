import 'package:flutter/material.dart';

class AppRoutes {
  static const initial = '/login';
  static final routes = <String, WidgetBuilder>{
    '/login': (_) => SizedBox.shrink(),
    '/home': (_) => SizedBox.shrink(),
  };
}
