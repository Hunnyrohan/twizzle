// lib/core/responsive.dart
import 'package:flutter/material.dart';

bool isTablet(BuildContext context) {
  final shortest = MediaQuery.of(context).size.shortestSide;
  return shortest >= 600;
}