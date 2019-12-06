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
  private static final String HR_CHANNEL_NAME = "hr";

  private EventChannel ppgChannel;
  private EventChannel hrChannel;

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
    hrChannel = new EventChannel(messenger, HR_CHANNEL_NAME);
    final StreamHandlerImpl hrScopeStreamHandler =
            new StreamHandlerImpl(sensorManager, Sensor.TYPE_HEART_RATE);
    hrChannel.setStreamHandler(hrScopeStreamHandler);
    List<Sensor> sensorList = sensorManager.getSensorList(Sensor.TYPE_ALL);
    ppgChannel = new EventChannel(messenger, PPG_CHANNEL_NAME);
    for (Sensor sensor : sensorList) {
      String sensorName = sensor.getStringType().toLowerCase();
      Log.d("sensorFound", sensorName + ":" + sensor.getType());
      if (sensorName.contains("ppg") || sensorName.contains("bio_hrm")) {
        int ppgSensorType = sensor.getType();
        Log.d("ppgSensorFound", sensorName + ":" + ppgSensorType);
        final StreamHandlerImpl ppgScopeStreamHandler =
                new StreamHandlerImpl(sensorManager, ppgSensorType);
        ppgChannel.setStreamHandler(ppgScopeStreamHandler);
      }
    }
  }

  private void teardownEventChannels() {
    ppgChannel.setStreamHandler(null);
    hrChannel.setStreamHandler(null);
  }
}
