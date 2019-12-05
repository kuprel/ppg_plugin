package io.kuprel.ppg;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.List;
import android.util.Log;

public class PpgPlugin implements FlutterPlugin {
  private static final String PPG_CHANNEL_NAME = "ppg";

  private EventChannel ppgChannel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    PpgPlugin plugin = new PpgPlugin();
    plugin.setupEventChannels(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final Context context = binding.getApplicationContext();
    setupEventChannels(context, binding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownEventChannels();
  }

  private void setupEventChannels(Context context, BinaryMessenger messenger) {
    SensorManager sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
    List<Sensor> sensorList = sensorManager.getSensorList(Sensor.TYPE_ALL);
    ppgChannel = new EventChannel(messenger, PPG_CHANNEL_NAME);
    int ppgSensorType = Sensor.TYPE_ACCELEROMETER;
    for (Sensor sensor : sensorList) {
      String sensorName = sensor.getStringType().toLowerCase();
      Log.d("sensorFound", sensorName + ":" + sensor.getType());
      if (sensorName.contains("ppg")) {
        ppgSensorType = sensor.getType();
        Log.d("ppgSensorFound", sensorName + ":" + ppgSensorType);
      }
    }
    final StreamHandlerImpl ppgScopeStreamHandler =
            new StreamHandlerImpl(sensorManager, ppgSensorType);
    ppgChannel.setStreamHandler(ppgScopeStreamHandler);

  }

  private void teardownEventChannels() {
    ppgChannel.setStreamHandler(null);
  }
}
