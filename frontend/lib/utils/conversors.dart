DateTime julian2DateTime(int julianDate) {
    int julianDay = julianDate;
    int j = julianDay + 32044;
    int g = j ~/ 146097;
    int dg = j % 146097;
    int c = ((dg ~/ 36524) + 1) * 3 ~/ 4;
    int dc = dg - c * 36524;
    int b = dc ~/ 1461;
    int db = dc % 1461;
    int a = (db ~/ 365) * 4 ~/ 4;
    int da = db - a * 365;
    int y = g * 400 + c * 100 + b * 4 + a;
    int m = (da * 5 + 308) ~/ 153 - 2;
    int d = da - (m + 4) * 153 ~/ 5 + 122;
    int year = y - 4800 + (m + 2) ~/ 12;
    int month = (m + 2) % 12 + 1;
    int day = d + 1;
    return DateTime(year, month, day);
}