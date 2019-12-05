import 'dart:async';
import 'package:ppg/ppg.dart';
import 'package:flutter/material.dart';

const int storeCount = 1024;
const double displayBeatCount = 2.5;
const double peakWindowMillis = 50;

void main() => runApp(HeartMonitor());

double abs(double x) => x > 0 ? x : -x;

class HeartMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PPG Example',
        debugShowCheckedModeBanner: false,
        home: Home(),
      );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<double> ppgData;
  double timestamp;
  bool ppgDetected = false;
  StreamSubscription<dynamic> _streamSubscription;

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = ppgEvents.listen(onNewData);
  }

  onNewData(PPGEvent e) {
    timestamp = e.t;
    ppgData = e.x;
    ppgDetected = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String txt = ppgDetected
        ? '$timestamp\n${ppgData[0]}\n${ppgData[1]}'
        : 'PPG not detected';
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text(txt, style: TextStyle(color: Colors.white))),
    );
  }
}
