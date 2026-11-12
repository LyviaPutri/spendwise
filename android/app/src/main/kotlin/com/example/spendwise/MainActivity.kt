package com.example.spendwise

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "spendwise/notifikasi"
    private var methodChannel: MethodChannel? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val title = intent.getStringExtra("title") ?: "Tanpa Judul"
            val text = intent.getStringExtra("text") ?: "Tanpa Teks"
            val pack = intent.getStringExtra("package") ?: "Tidak diketahui"
            
            val info = "Dari: $pack\nJudul: $title\nIsi: $text"
            methodChannel?.invokeMethod("notifikasiMasuk", info)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "cekIzin") {
                result.success(NotificationManagerCompat.getEnabledListenerPackages(this).contains(packageName))
            } else if (call.method == "bukaPengaturan") {
                startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        // PENTING: Gunakan ContextCompat agar receiver aman dari error pembatasan Android 13+
        ContextCompat.registerReceiver(this, receiver, IntentFilter("NOTIFIKASI_MASUK"), ContextCompat.RECEIVER_NOT_EXPORTED)
    }

    override fun onDestroy() {
        unregisterReceiver(receiver)
        super.onDestroy()
    }
}