import 'package:intl/intl.dart';
import 'package:verygoodweatherapp/models/days.dart';

class Time {
  // Returns in h:mm AMPM format (e.g. 7:50PM)
  String getTimeNow() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('h:mma').format(now);
    return formattedDate;
  }

  // Returns list of future day names, starting with 'Tomorrow'
  List<String> getFutureDays() {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE').format(now);
    List<String> futureDays = _futureDayCreator(day);

    return futureDays;
  }

  // Converts the zulu time of the weather to local time in h:mm AMPM format (e.g. 7:50PM)
  String convertZuluTime(int timeZulu) {
    DateTime dateTimeGMT = DateTime.fromMillisecondsSinceEpoch(timeZulu * 1000);

    //var dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(timeZulu, true);
    String formattedDate = DateFormat('h:mma').format(dateTimeGMT);
    return formattedDate;
  }

  String scrapeTime24Hr(String localtime) {
    String scrapedTime = localtime.substring(localtime.length - 5);
    return scrapedTime;
  }

  double calculateTimeLine(String currTime) {
    String hrs = currTime.substring(0, 2);
    if (hrs.endsWith(':')) {
      hrs = hrs.substring(0, hrs.length - 1);
    }
    if (hrs.startsWith(' ')) {
      hrs = hrs.trimLeft();
    }
    String minsString = currTime.substring(currTime.length - 2);
    double mins =
        double.parse((double.parse(minsString) / 60).toStringAsFixed(1));
    return double.parse(hrs) + mins;
  }

  // Generates future day names from a passed in day name
  List<String> _futureDayCreator(String day) {
    List<String> futureDays = List<String>.filled(5, 'Day');
    switch (day) {
      case 'Sunday':
        {
          futureDays = [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri];
        }
        break;
      case 'Monday':
        {
          futureDays = [Days.tue, Days.wed, Days.thu, Days.fri, Days.sat];
        }
        break;
      case 'Tuesday':
        {
          futureDays = [Days.wed, Days.thu, Days.fri, Days.sat, Days.sun];
        }
        break;
      case 'Wednesday':
        {
          futureDays = [Days.thu, Days.fri, Days.sat, Days.sun, Days.mon];
        }
        break;
      case 'Thursday':
        {
          futureDays = [Days.fri, Days.sat, Days.sun, Days.mon, Days.tue];
        }
        break;
      case 'Friday':
        {
          futureDays = [Days.sat, Days.sun, Days.mon, Days.tue, Days.wed];
        }
        break;
      case 'Saturday':
        {
          futureDays = [Days.sun, Days.mon, Days.tue, Days.wed, Days.thu];
        }
        break;
    }

    return futureDays;
  }
}
