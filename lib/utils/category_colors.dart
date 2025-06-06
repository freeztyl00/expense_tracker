import 'package:flutter/material.dart';

// Повертає колір для категорії на основі її хешу
Color getCategoryColor(String category) {
  final index = category.hashCode % Colors.primaries.length;
  return Colors.primaries[index];
}
