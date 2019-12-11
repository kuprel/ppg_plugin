# ppg

A Flutter plugin to access the PPG sensor.

This plugin is a modification of [sensors](https://pub.dev/packages/sensors).
I have tested it to read the PPG sensor in WearOS with both
a Fossil Sport and a Fossil Gen 5.
This plugin only supports Android. I don't know if it is even possible to read
the raw PPG data from Apple WatchOS yet, but it would be super cool if someone
could add that functionality.
Both of the WearOS watches I tested with had a sensor of type
`com.google.wear.sensor.ppg`.
This plugin will detect a PPG sensor if its type contains `ppg`

Update: I used this plugin to make a simple heart monitoring app
[link](https://play.google.com/store/apps/details?id=io.kuprel.heart_monitor)

## Usage

This plugin exposes `Stream`s of `PPGEvent`s and `HREvent`s

### Example

```dart
import 'package:ppg/ppg.dart';

ppgEvents.listen((PPGEvent event) {
  print(event);
});
// [PPGEvent (x: [0.0, 0.0], t: 0.0)]

hrEvents.listen((HREvent event) {
  print(event);
});
// [HREvent (x: 0.0, t: 0.0)]

```

Also see the `example` subdirectory for an example application that uses
PPG data.
