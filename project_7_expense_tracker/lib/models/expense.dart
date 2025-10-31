import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0)
  Food,
  @HiveField(1)
  Transport,
  @HiveField(2)
  Work,
  @HiveField(3)
  Fun,
}

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final ExpenseCategory category;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = Uuid().v4();
}