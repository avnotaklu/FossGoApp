import 'package:go/utils/core_utils.dart';

import 'package:firebase_database/firebase_database.dart';

class TimeAndDuration {
  final DateTime _time;
  final Duration _duration;
  TimeAndDuration(this._time, this._duration);
  TimeAndDuration.fromString(String str)
      : _time = DateTime.parse(str.split("|")[0]),
        _duration = parseDurationFromString(str.split("|")[1]);
  @override
  String toString() {
    return _time.toString() + "|" + _duration.toString();
  }

  get datetime => _time;
  get duration => _duration;
}

updateTimeInDatabase(DatabaseReference ref, DateTime time, int player) {
  ref.child('lastTimeAndDuration').child((player).toString()).orderByKey().get().then((value) {
    print(value);
    ref
        .child('lastTimeAndDuration')
        .update({(player).toString(): TimeAndDuration(time, TimeAndDuration.fromString(value.value as String).duration).toString()});
  });
}

updateDurationInDatabase(DatabaseReference ref, Duration dur, int player) {
  ref.child('lastTimeAndDuration').child((player).toString()).orderByKey().get().then((value) {
    print(value);
    ref
        .child('lastTimeAndDuration')
        .update({(player).toString(): TimeAndDuration(TimeAndDuration.fromString(value.value as String)._time, dur).toString()});
  });
}
