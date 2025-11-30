package com.example.AccountMgmt

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.account_mgmt/deep_link"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle the intent that started the activity
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle new intents while the activity is running
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val appLinkAction = intent?.action
        val appLinkData = intent?.data

        if (Intent.ACTION_VIEW == appLinkAction && appLinkData != null) {
            if ("/open_add_expense" == appLinkData.path) {
                // Use MethodChannel to notify Flutter
                flutterEngine?.dartExecutor?.binaryMessenger?.let {
                    MethodChannel(it, CHANNEL).invokeMethod("open_add_expense_screen", null)
                }
            }
        }
    }
}
