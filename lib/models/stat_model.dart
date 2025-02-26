import '/constant/enums.dart';

class StatModel {
  final int index;
  final dynamic value;
  final String title;
  final StatisticType type;
  bool isAdCell = false;
  StatModel({
    required this.index,
    required this.value,
    required this.title,
    required this.type,
    bool? isAdCell = false,
  }) {
    this.isAdCell = isAdCell ?? false;
  }
}
