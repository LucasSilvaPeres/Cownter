import 'package:intl/intl.dart';

extension dateOnly on DateTime {
  get formattedDate {
    DateFormat format;
    format = DateFormat("dd/MM/yyyy");
    return format.format(this);
  }

  get formattedDateHour {
    DateFormat format;
    format = DateFormat("dd/MM/yyyy hh:mm");
    return format.format(this);
  }

  String get formattedDateDDMMYY {
    DateFormat formater = DateFormat("dd/MM/yy");

    return formater.format(this);
  }
}

extension JulianDateTime on DateTime {
  int get toJulian {
    int year = this.year;
    int month = this.month;
    int day = this.day;
    if (month < 3) {
      year -= 1;
      month += 12;
    }
    int a = year ~/ 100;
    int b = a ~/ 4;
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();
    int julianDay = c + day + e + f - 1524;
    return julianDay;
  }
}
