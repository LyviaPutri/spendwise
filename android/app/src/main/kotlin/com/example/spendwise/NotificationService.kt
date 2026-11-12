package com.example.spendwise

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.widget.Toast

class NotificationService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        val title = extras.getString("android.title") ?: "Tanpa Judul"
        val text = extras.getCharSequence("android.text")?.toString() ?: "Tanpa Teks"

        // PELACAK VISUAL: Memunculkan teks pop-up hitam di bawah layar HP
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(applicationContext, "SENSOR BACA: $title", Toast.LENGTH_SHORT).show()
        }

        val intent = Intent("NOTIFIKASI_MASUK")
        intent.setPackage(applicationContext.packageName)
        intent.putExtra("package", packageName)
        intent.putExtra("title", title)
        intent.putExtra("text", text)
        sendBroadcast(intent)
    }
}