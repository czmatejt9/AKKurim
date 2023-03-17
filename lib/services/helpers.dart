import 'dart:math';
import 'package:week_of_year/week_of_year.dart';

class Helper {
  String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  bool isSameWeek(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.weekOfYear == date2.weekOfYear;
  }

  String getHourMinute(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String getDayMonth(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}. ${date.month.toString().padLeft(2, '0')}.';
  }

  String getDayMonthYear(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}. ${date.month.toString().padLeft(2, '0')}. ${date.year}';
  }

  DateTime midnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int getCountBetweenDates(DateTime date1, DateTime date2) {
    return midnight(date2).difference(midnight(date1)).inDays.abs();
  }

  int getWeeksBetweenDates(DateTime date1, DateTime date2) {
    return getCountBetweenDates(date1, date2) ~/ 7;
  }

  int getCountOfTrainingsBetweenDates(DateTime date1, DateTime date2) {
    return getWeeksBetweenDates(date1, date2) + 1;
  }

  String getCzechEnding(int number) {
    if (number == 1) {
      return '';
    } else if (number >= 2 && number <= 4) {
      return 'y';
    } else {
      return 'ů';
    }
  }
}
