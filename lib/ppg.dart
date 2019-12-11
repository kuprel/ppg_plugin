import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _ppgEventChannel = EventChannel('ppg');
const EventChannel _hrEventChannel = EventChannel('hr');

// Is there a better way to do this?
List<double> _toList(obj) => obj.cast<double>();

class PPGEvent {
  PPGEvent(Object event)
      : x = _toList(event).sublist(0, _toList(event).length - 1),
        t = _toList(event)[_toList(event).length - 2],
        accuracy = _toList(event).last.toInt();
  final List<double> x;
  final double t;
  final int accuracy;
  @override
  String toString() => '[PPGEvent (x: $x, t: $t, accuracy: $accuracy)]';
}

class HREvent {
  HREvent(Object event)
      : x = _toList(event).first,
        t = _toList(event)[_toList(event).length - 2],
        accuracy = _toList(event).last.toInt();
  final double x, t;
  final int accuracy;
  @override
  String toString() => '[HREvent (x: $x, t: $t, accuracy: $accuracy)]';
}

Stream<PPGEvent> get ppgEvents => _ppgEventChannel
    .receiveBroadcastStream()
    .map((Object event) => PPGEvent(event));

Stream<HREvent> get hrEvents => _hrEventChannel
    .receiveBroadcastStream()
    .map((Object event) => HREvent(event));
