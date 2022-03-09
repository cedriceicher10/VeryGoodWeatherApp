import 'package:intl/intl.dart';

class Time {
  // Returns in h:mm AMPM format (7:50PM)
  String getTimeNow() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('h:mma').format(now);
    return formattedDate;
  }
}
