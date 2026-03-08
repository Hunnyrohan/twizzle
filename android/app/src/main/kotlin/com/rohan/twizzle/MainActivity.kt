package com.rohan.twizzle.app

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterFragmentActivity(), SensorEventListener {
    private val TAG = "TwizzleLightSensor"
    private val CHANNEL = "com.rohan.twizzle/light_sensor"
    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Initializing Light Sensor...")
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)

        if (lightSensor == null) {
            Log.e(TAG, "Light sensor NOT found on this device!")
        } else {
            Log.d(TAG, "Light sensor found: ${lightSensor?.name}")
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "Flutter is listening to light sensor")
                    eventSink = events
                    
                    if (lightSensor == null) {
                        events?.error("SENSOR_MISSING", "Hardware light sensor not found on this device", null)
                        return
                    }

                    val registered = sensorManager?.registerListener(this@MainActivity, lightSensor, SensorManager.SENSOR_DELAY_UI)
                    Log.d(TAG, "Sensor listener registered: $registered")
                    
                    if (registered == false) {
                        events?.error("REGISTRATION_FAILED", "Could not register light sensor listener", null)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "Flutter stopped listening to light sensor")
                    sensorManager?.unregisterListener(this@MainActivity)
                    eventSink = null
                }
            }
        )
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_LIGHT) {
            val lux = event.values[0]
            Log.v(TAG, "Lux value changed: $lux") // Verbose logging for high-frequency data
            eventSink?.success(lux.toDouble())
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        Log.d(TAG, "Sensor accuracy changed: $accuracy")
    }
}
