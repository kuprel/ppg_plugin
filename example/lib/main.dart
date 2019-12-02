import 'package:ppg/ppg.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

const int sampleCount = 100;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'PPG Monitor',
        debugShowCheckedModeBanner: false,
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> data = List<double>.filled(sampleCount, 0);
  int index = 0;
  double dataMean = 0, dataMax = 1;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final CustomPaint graph = CustomPaint(
      painter: PathPainter(
        data: data,
        index: index,
        dataMean: dataMean,
        dataMax: dataMax,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      // body: SizedBox.expand(child: graph),
      body: Container(
        child: graph,
        width: double.infinity,
        height: double.infinity,
      ),
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
    _streamSubscriptions.add(ppgEvents.listen(onNewData));
  }

  abs(double i) => i > 0 ? i : -i;

  onNewData(PPGEvent e) {
    data[index % sampleCount] = e.x;
    index++;

    if (index % 1000 == 0) {
      print('dataMean: $dataMean');
      print('dataMax: $dataMax');
    }

    dataMean = 0.99 * dataMean + 0.01 * e.x;
    absDiff(double i) => dataMean - i > 0 ? dataMean - i : i - dataMean;
    dataMax = 0.95 * dataMax + 0.05 * data.map(absDiff).reduce(max);
    setState(() {});
  }
}

class PathPainter extends CustomPainter {
  PathPainter({this.data, this.index, this.dataMean, this.dataMax});
  final int index;
  final List<double> data;
  final double dataMean, dataMax;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path path = Path()..moveTo(0, size.height / 2);

    for (int i in Iterable<int>.generate(sampleCount)) {
      final double x = size.width * i / sampleCount;
      double y = data[(index + i) % sampleCount];
      y -= dataMean;
      y /= dataMax;
      y = size.height * 0.5 * (1 + 0.5 * y);
      if (i == 0) path.moveTo(x, y);
      if (i > 0) path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
}
