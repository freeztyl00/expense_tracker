import 'package:flutter/material.dart';

Color getCategoryColor(String category) {
  final index = category.hashCode % Colors.primaries.length;
  return Colors.primaries[index];
}
