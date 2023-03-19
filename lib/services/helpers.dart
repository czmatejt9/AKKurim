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

  bool isWithinNextWeek(DateTime date) {
    DateTime now = DateTime.now();
    return getCountBetweenDates(now, date) <= 7 &&
        getCountBetweenDates(DateTime.now(), date) >= 0 &&
        date.isAfter(now);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int getWeeksBetweenDates(DateTime date1, DateTime date2) {
    return getCountBetweenDates(date1, date2) ~/ 7;
  }

  int getCountOfTrainingsBetweenDates(DateTime date1, DateTime date2) {
    return getWeeksBetweenDates(date1, date2) + 1;
  }

  String getCzechDayName(DateTime date) {
    int index = date.weekday;
    List<String> days = [
      'pondělí',
      'úterý',
      'středa',
      'čtvrtek',
      'pátek',
      'sobota',
      'neděle'
    ];
    return days[index - 1];
  }

  String getCzechMonthName(DateTime date) {
    int index = date.month;
    List<String> months = [
      'ledna',
      'února',
      'března',
      'dubna',
      'května',
      'června',
      'července',
      'srpna',
      'září',
      'října',
      'listopadu',
      'prosince'
    ];
    return months[index - 1];
  }

  String getCzechDayAndDate(DateTime date) {
    return '${getCzechDayName(date)} ${date.day}. ${getCzechMonthName(date)}';
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
