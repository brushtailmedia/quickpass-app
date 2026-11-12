package com.quickpass.app

import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge

class MainActivity : TauriActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    enableEdgeToEdge()
    super.onCreate(savedInstanceState)
    // Block screenshots, screen recording and the recents thumbnail: passwords are on screen.
    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    // Phones stay portrait; tablets rotate freely (Play's large-screen guidelines, and Android 16+
    // ignores orientation locks on large screens anyway).
    if (!resources.getBoolean(R.bool.is_tablet)) {
      requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }
  }
}
