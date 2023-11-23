import 'package:week_of_year/week_of_year.dart';

class Helper {
  static bool isSameWeek(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.weekOfYear == date2.weekOfYear;
  }

  static String getHourMinute(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String getYearMonth(DateTime date) {
    return '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}';
  }

  static String getDayMonth(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}. ${date.month.toString().padLeft(2, '0')}.';
  }

  static String getDayMonthYear(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}. ${date.month.toString().padLeft(2, '0')}. ${date.year}';
  }

  static DateTime midnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int getCountBetweenDates(DateTime date1, DateTime date2) {
    return midnight(date2).difference(midnight(date1)).inDays.abs();
  }

  static String getTimeCountdown(DateTime date) {
    int days = getCountBetweenDates(DateTime.now(), date);
    if (days == 0) {
      return 'dnes';
    } else if (days == 1) {
      return 'zítra';
    } else if (days == 2) {
      return 'pozítří';
    } else if (days < 5) {
      return 'za $days dny';
    } else {
      return 'za $days dní';
    }
  }

  static bool isWithinNextWeek(DateTime date) {
    DateTime now = DateTime.now();
    return getCountBetweenDates(now, date) < 7 &&
        getCountBetweenDates(DateTime.now(), date) >= 0 &&
        date.isAfter(midnight(now));
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static int getWeeksBetweenDates(DateTime date1, DateTime date2) {
    return getCountBetweenDates(date1, date2) ~/ 7;
  }

  static int getCountOfTrainingsBetweenDates(DateTime date1, DateTime date2) {
    return getWeeksBetweenDates(date1, date2) + 1;
  }

  static String getCzechDayName(DateTime date) {
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

  static String getCzechMonthName(DateTime date) {
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

  static String getCzechDayAndDate(DateTime date) {
    return '${getCzechDayName(date)} ${date.day}. ${getCzechMonthName(date)}';
  }

  static String getCzechMonthAndYear(DateTime date) {
    List<String> months = [
      'leden',
      'únor',
      'březen',
      'duben',
      'květen',
      'červen',
      'červenec',
      'srpen',
      'září',
      'říjen',
      'listopad',
      'prosinec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String getCzechEnding(int number) {
    if (number == 1) {
      return '';
    } else if (number >= 2 && number <= 4) {
      return 'y';
    } else {
      return 'ů';
    }
  }

  static bool isBeforeToday(DateTime date) {
    return midnight(date).isBefore(midnight(DateTime.now()));
  }

  static int getSecondsFromMidnight(DateTime date) {
    return date.difference(midnight(date)).inSeconds.abs();
  }

  static int getSecondsFromTimeString(String timeString) {
    List<String> time = timeString.split(':');
    return int.parse(time[0]) * 3600 + int.parse(time[1]) * 60;
  }

  /// Get today's date with time from timeString. (e.g. 22:00)
  static DateTime fromTimeString(String timeString) {
    List<String> time = timeString.split(':');
    // get current date
    DateTime now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, int.parse(time[0]), int.parse(time[1]));
  }

  static Duration getInitialDelay(DateTime to) {
    DateTime now = DateTime.now();
    if (to.isBefore(now)) {
      // add one day
      to = to.add(const Duration(days: 1));
    }

    return to.difference(now);
  }

  /// Get formated string how long ago something happened.
  ///
  /// Provide either a dateTime object OR iso string,
  /// Throws assertion error if both are provided.
  static String getAgoString({String? timeString, DateTime? dateTimeObject}) {
    assert(timeString == null || dateTimeObject == null);

    if (timeString != null) {
      dateTimeObject = DateTime.parse(timeString);
    }

    DateTime now = DateTime.now();
    Duration diff = now.difference(dateTimeObject!);

    if (diff.inSeconds < 120) {
      return 'před méne než 2 minutami';
    } else if (diff.inMinutes < 60) {
      return 'před ${diff.inMinutes} minutami';
    } else if (diff.inHours < 24) {
      return 'před ${diff.inHours} hodinami';
    } else if (diff.inDays < 2) {
      return 'před ${diff.inDays} dnem a ${diff.inHours % 24} hodinami';
    } else {
      return 'před více než ${diff.inDays} dny';
    }
  }
}
