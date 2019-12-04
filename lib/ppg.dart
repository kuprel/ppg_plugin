import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _ppgEventChannel = EventChannel('ppg');

class PPGEvent {
  PPGEvent(this.x, this.t);
  final List<double> x;
  final double t;
  @override
  String toString() => '[PPGEvent (x: $x)]';
}

PPGEvent _listToPPGEvent(List<double> list) {
  return PPGEvent(list.sublist(0, list.length - 1), list.last);
}

Stream<PPGEvent> _ppgEvents;

Stream<PPGEvent> get ppgEvents {
  if (_ppgEvents == null) {
    _ppgEvents = _ppgEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToPPGEvent(event.cast<double>()));
  }
  return _ppgEvents;
}
