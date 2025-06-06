import 'package:flutter/material.dart';

// Іконки для кожної категорії
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

// Перелік категорій витрат
final List<String> expenseCategories = [
  'Їжа',
  'Транспорт',
  'Розваги',
  'Дім',
  'Одяг',
  'Тварини',
  'Інше',
];

// Перелік категорій доходів
final List<String> incomeCategories = ['Зарплата', 'Подарунок', 'Продаж'];
