import 'package:flutter/material.dart';

final Map<String, IconData> categoryIcons = {
  'Їжа': Icons.restaurant,
  'Транспорт': Icons.directions_car,
  'Розваги': Icons.movie,
  'Дім': Icons.home,
  'Одяг': Icons.checkroom,
  'Тварини': Icons.pets,
  'Інше': Icons.more_horiz,
  'Зарплата': Icons.attach_money,
  'Подарунок': Icons.card_giftcard,
  'Продаж': Icons.storefront,
};

final List<String> expenseCategoriesList = [
  'Їжа',
  'Транспорт',
  'Розваги',
  'Дім',
  'Одяг',
  'Тварини',
  'Інше',
];

final List<String> incomeCategoriesList = ['Зарплата', 'Подарунок', 'Продаж'];

Color getCategoryColor(String category) {
  final index = category.hashCode % Colors.primaries.length;
  return Colors.primaries[index];
}
