// Модель користувача застосунку
class AppUser {
  final String id;
  final String email;
  final double? initialBalance;

  // Конструктор користувача
  AppUser({required this.id, required this.email, this.initialBalance});
}
