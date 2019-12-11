import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_state.dart';

void main() {
  final AppState state = AppState();

  final MaterialApp app = MaterialApp(
    title: 'PPG Example',
    debugShowCheckedModeBanner: false,
    home: ScopedModel<AppState>(model: state, child: PPGExample()),
  );

  runApp(app);

  state.initPPG();

  handlePermissionResponse(Map<PermissionGroup, PermissionStatus> status) {
    if (status[PermissionGroup.sensors] == PermissionStatus.granted) {
      state.initHR();
    }
  }

  handlePermissionStatus(PermissionStatus status) => status ==
          PermissionStatus.granted
      ? state.initHR()
      : PermissionHandler()
          .requestPermissions(<PermissionGroup>[PermissionGroup.sensors]).then(
              handlePermissionResponse);

  PermissionHandler()
      .checkPermissionStatus(PermissionGroup.sensors)
      .then(handlePermissionStatus);
}

class PPGExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState state = ScopedModel.of<AppState>(
      context,
      rebuildOnChange: true,
    );

    final String ppgTxt = !state.ppgDetected
        ? 'PPG not detected'
        : 'Channel 1: ${state.ppgData[0]}\n'
            'Channel 2: ${state.ppgData[1]}\n'
            'timestamp: ${state.ppgTimestamp.round()}\n'
            'accuracy: ${state.ppgAccuracy}';

    final String hrTxt = !state.hrPermission
        ? 'Permission not granted'
        : !state.hrDetected
            ? 'Reading...'
            : '${state.hrData.round()} bpm\n'
                'timestamp: ${state.hrTimestamp.round()}\n'
                'accuracy: ${state.hrAccuracy}';

    final String txt = 'PPG\n$ppgTxt\n\nHeart Rate\n$hrTxt';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
        child: Text(
          txt,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
