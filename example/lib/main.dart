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
  double hrData;
  double ppgTimestamp, hrTimestamp;
  bool ppgDetected = false, hrDetected = false;
  StreamSubscription<dynamic> _ppgStreamSubscription, _hrStreamSubscription;

  @override
  void dispose() {
    super.dispose();
    _ppgStreamSubscription.cancel();
    _hrStreamSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _ppgStreamSubscription = ppgEvents.listen(onNewPPGData);
    _hrStreamSubscription = hrEvents.listen(onNewHRData);
  }

  onNewPPGData(PPGEvent e) {
    ppgTimestamp = e.t;
    ppgData = e.x;
    ppgDetected = true;
    setState(() {});
  }

  onNewHRData(HREvent e) {
    hrTimestamp = e.t;
    hrData = e.x;
    hrDetected = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String ppgTxt = ppgDetected
        ? '$ppgTimestamp\n${ppgData[0]}\n${ppgData[1]}'
        : 'PPG not detected';
    final String hrTxt =
        hrDetected ? '$hrTimestamp\n$hrData' : 'HR not detected';
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          ppgTxt + '\n' * 2 + hrTxt,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
