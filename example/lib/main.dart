import 'dart:async';
import 'dart:math';
import 'package:ppg/ppg.dart';
import 'package:flutter/material.dart';

const int storeCount = 1024;
const double displayBeatCount = 2.5;
const double peakWindowMillis = 50;

void main() => runApp(HeartMonitor());

double abs(double x) => x > 0 ? x : -x;

class HeartMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'PPG Monitor',
        debugShowCheckedModeBanner: false,
        home: Home(title: 'Flutter Demo Home Page'),
      );
}

class Home extends StatefulWidget {
  const Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int displayCount, index = 0;
  List<double> ppg, timestamps;
  List<bool> isPeak;
  double ppgMean = 0, ppgMax = 1, peakTime;
  double dataSmoothing = 0, sampleInterval = 10, hrv = 100;
  double beatInterval = 1000, measuredBeatInterval = 1000;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  int get heartRate => (60e3 / beatInterval).round();
  int get beatCount => isPeak.fold(0, (int t, bool i) => i ? t + 1 : t);

  @override
  Widget build(BuildContext context) {
    final double mH = MediaQuery.of(context).size.height / 1000;

    final CustomPaint graph = CustomPaint(
      painter: PulseTrace(
        data: ppg,
        index: index,
        dataMean: ppgMean,
        dataMax: ppgMax,
        isPeak: isPeak,
        displayCount: displayCount,
      ),
    );

    final Container heartBeatText = Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 80 * mH),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(text: '$heartRate ', style: TextStyle(fontSize: 120 * mH)),
            TextSpan(text: 'BPM\n', style: TextStyle(fontSize: 70 * mH)),
            TextSpan(
                text: '${hrv.round()} ', style: TextStyle(fontSize: 80 * mH)),
            TextSpan(text: 'ms HRV', style: TextStyle(fontSize: 55 * mH)),
          ],
        ),
      ),
    );

    final Container sampleRateText = Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 50 * mH),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 80 * mH,
          ),
          children: <TextSpan>[
            TextSpan(text: '${(1000 / sampleInterval).round()} '),
            TextSpan(text: 'HZ', style: TextStyle(fontSize: 70 * mH)),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: <Widget>[
        SizedBox.expand(child: graph),
        heartBeatText,
        sampleRateText,
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    displayCount = storeCount;
    ppg = List<double>.filled(storeCount, 0);
    timestamps = List<double>.filled(storeCount, 0);
    isPeak = List<bool>.filled(storeCount, false);
    _streamSubscriptions.add(ppgEvents.listen(onNewData));
  }

  onNewData(PPGEvent e) {
    timestamps[index % storeCount] = e.t;

    final double newData = e.x[0] + e.x[1];
    final double oldData = ppg[(index - 1) % storeCount];

    if (index == 40) {
      ppgMean = ppg.reduce((double i, double j) => i + j) / index;
      for (int i in Iterable<int>.generate(storeCount - index)) {
        ppg[i + index] = ppgMean;
      }
      ppgMax = ppg.map((double i) => abs(i - ppgMean)).reduce(max);
    }

    if ((index + 1) % (500 / max(sampleInterval, 1)).ceil() == 0) {
      if (beatInterval < 300 || (hrv > 200 && beatInterval < 1500)) {
        dataSmoothing = 0.1 + 0.9 * dataSmoothing;
      } else if (beatInterval > 2000) {
        dataSmoothing = 0.9 * dataSmoothing;
      }
    }

    ppg[index % storeCount] =
        dataSmoothing * oldData + (1 - dataSmoothing) * newData;

    sampleInterval = 0.9 * sampleInterval +
        0.1 * (e.t - timestamps[(index - 1) % storeCount]);

    final int dj = (peakWindowMillis / sampleInterval).round();
    final int j0 = index % storeCount;
    final int j1 = (index - dj) % storeCount;
    final int j2 = (index - 2 * dj) % storeCount;

    isPeak[j1] = false;
    if ((ppg[j0] > ppg[j1]) && (ppg[j2] > ppg[j1])) {
      if (peakTime == null || e.t - peakTime > beatInterval / 2) {
        isPeak[j1] = true;
        final double newBeatInterval =
            peakTime == null ? beatInterval : e.t - peakTime;
        hrv = 0.99 * hrv + 0.01 * abs(newBeatInterval - measuredBeatInterval);
        measuredBeatInterval = newBeatInterval;
        beatInterval = 0.9 * beatInterval + 0.1 * measuredBeatInterval;
        peakTime = e.t;
      }
    }

    ppgMean = 0.999 * ppgMean + 0.001 * newData;

    double newMax = 0;
    for (int i in Iterable<int>.generate(min(displayCount, index))) {
      final int j = (index + i - 1 + storeCount - displayCount) % storeCount;
      newMax = max(newMax, abs(ppg[j] - ppgMean));
    }
    ppgMax = 0.95 * ppgMax + 0.05 * newMax;

    if ((index + 1) % (200 / max(sampleInterval, 1)).ceil() == 0) {
      double newDisplayCount =
          displayBeatCount / max(1, beatCount) * min(storeCount, index);
      newDisplayCount = min(max(50, newDisplayCount), storeCount.toDouble());
      displayCount = (0.9 * displayCount + 0.1 * newDisplayCount).round();
    }

    index++;

    setState(() {});
  }
}

class PulseTrace extends CustomPainter {
  PulseTrace({
    this.data,
    this.index,
    this.dataMean,
    this.dataMax,
    this.isPeak,
    this.displayCount,
  });

  final int index, displayCount;
  final List<double> data;
  final List<bool> isPeak;
  final double dataMean, dataMax;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pathPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final Paint peakCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint leadCircle = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Path path = Path();

    double x, y;

    for (int i in Iterable<int>.generate(displayCount)) {
      x = size.width * i / displayCount * 0.8;
      final int j = (index + i + (storeCount - displayCount)) % storeCount;
      y = (data[j] - dataMean) / dataMax;
      y = size.height * 0.5 * (1.2 + 0.3 * y);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      if (isPeak[j]) canvas.drawCircle(Offset(x, y), 6, peakCircle);
    }

    canvas
      ..drawPath(path, pathPaint)
      ..drawCircle(Offset(x, y), 6, leadCircle);
  }
}
