import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isMobile => ResponsiveBreakpoints.of(this).isMobile;
  bool get isPhone => ResponsiveBreakpoints.of(this).isPhone;
  bool get isTablet => ResponsiveBreakpoints.of(this).isTablet;
  bool get isDesktop => ResponsiveBreakpoints.of(this).isDesktop;

  bool largerThan(String name) =>
      ResponsiveBreakpoints.of(this).largerThan(name);
  bool smallerThan(String name) =>
      ResponsiveBreakpoints.of(this).smallerThan(name);

  bool largerOrEqualTo(String name) =>
      ResponsiveBreakpoints.of(this).largerOrEqualTo(name);
  bool smallerOrEqualTo(String name) =>
      ResponsiveBreakpoints.of(this).smallerOrEqualTo(name);

  bool equals(String name) => ResponsiveBreakpoints.of(this).equals(name);
  bool between(String name, String name1) =>
      ResponsiveBreakpoints.of(this).between(name, name1);

  // double get breakpoint => ResponsiveBreakpoints.of(this).;
}
