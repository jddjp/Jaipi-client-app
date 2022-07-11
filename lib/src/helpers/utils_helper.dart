import 'dart:math';

import 'package:jaipi/src/config/constants.dart';

const _chars = '1234567890';
Random _rnd = Random();

// Create a random string
String getUID(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

// Parse string to int time
int parseTime(String time) {
  List splitted = time.split('');

  if (splitted[0] == '0') {
    return int.parse(splitted[1]);
  }

  return int.parse(time);
}

bool isOpenBusiness(Map<String, dynamic> business) {
  final now = DateTime.now();
  final weekDay = WEEK_DAYS[now.weekday.toString()];
  final currentSchedule = business['schedules'] != null && business['schedules'][weekDay] != null
      ? business['schedules'][weekDay]
      : null;

  if (currentSchedule != null &&
      currentSchedule['opening_time'] != "" &&
      currentSchedule['closing_time'] != "") {
    List open = currentSchedule['opening_time'].toString().split(':');
    List close = currentSchedule['closing_time'].toString().split(':');
    final openingTime = DateTime(
        now.year, now.month, now.day, parseTime(open[0]), parseTime(open[1]));
    final closingTime = DateTime(
        now.year, now.month, now.day, parseTime(close[0]), parseTime(close[1]));
    if ((now.isAfter(openingTime) && now.isBefore(closingTime)) ||
        (now.isBefore(closingTime) &&
            closingTime.difference(now).inMinutes < 30)) {
      return true;
    }
  }

  return false;
}

bool isBusinessClosed(Map<String,dynamic> business) {
    final now = DateTime.now();
    final weekDay = WEEK_DAYS[now.weekday.toString()];
    final currentSchedule = business['schedules'][weekDay] != null
        ? business['schedules'][weekDay]
        : null;

    // Is online?
    /* if (business['online'] == null || business['online'] == false) {
      return false;
    } */

    if (currentSchedule != null &&
        currentSchedule['opening_time'] != "" &&
        currentSchedule['closing_time'] != "") {
      List open = currentSchedule['opening_time'].toString().split(':');
      List close = currentSchedule['closing_time'].toString().split(':');
      final openingTime = DateTime(
          now.year, now.month, now.day, parseTime(open[0]), parseTime(open[1]));
      final closingTime = DateTime(now.year, now.month, now.day,
          parseTime(close[0]), parseTime(close[1]));
      if ((now.isAfter(openingTime) && now.isBefore(closingTime)) ||
          (now.isBefore(closingTime) &&
              closingTime.difference(now).inMinutes < 30)) {
        return false;
      }
    }

    return true;
  }
