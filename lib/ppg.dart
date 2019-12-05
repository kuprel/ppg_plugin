import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _ppgEventChannel = EventChannel('ppg');
const EventChannel _hrEventChannel = EventChannel('kuprel.hr');

class PPGEvent {
  PPGEvent(this.x, this.t);
  final List<double> x;
  final double t;
  @override
  String toString() => '[PPGEvent (x: $x, t: $t)]';
}

class HREvent {
  HREvent(this.x, this.t);
  final double x;
  final double t;
  @override
  String toString() => '[HREvent (x: $x, t: $t)]';
}

PPGEvent _listToPPGEvent(List<double> list) =>
    PPGEvent(list.sublist(0, list.length - 1), list.last);

HREvent _listToHREvent(List<double> list) => HREvent(list.first, list.last);

Stream<PPGEvent> _ppgEvents;
Stream<HREvent> _hrEvents;

Stream<PPGEvent> get ppgEvents {
  if (_ppgEvents == null) {
    _ppgEvents = _ppgEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToPPGEvent(event.cast<double>()));
  }
  return _ppgEvents;
}

Stream<HREvent> get hrEvents {
  if (_hrEvents == null) {
    _hrEvents = _hrEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToHREvent(event.cast<double>()));
  }
  return _hrEvents;
}
