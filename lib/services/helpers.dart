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
}
