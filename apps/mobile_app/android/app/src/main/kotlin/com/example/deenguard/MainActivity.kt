package com.example.deenguard

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.deenguard/vpn"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        startActivityForResult(intent, 0)
                        result.success(false) // Not started yet, needs permission
                    } else {
                        onActivityResult(0, RESULT_OK, null)
                        result.success(true) // Already had permission, started
                    }
                }
                "stopVpn" -> {
                    val stopIntent = Intent(this, DeenGuardVpnService::class.java)
                    stopIntent.action = "STOP_VPN"
                    startService(stopIntent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 0 && resultCode == RESULT_OK) {
            val startIntent = Intent(this, DeenGuardVpnService::class.java)
            startService(startIntent)
        }
    }
}
