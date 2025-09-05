import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 0)
class Income {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String description;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final String category;
  
  Income({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}