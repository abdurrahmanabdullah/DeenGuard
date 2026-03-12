package com.example.deenguard

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.IBinder
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.deenguard/vpn"
    private val AD_SKIP_CHANNEL = "com.example.deenguard/adskip"
    
    private var vpnService: DeenGuardVpnService? = null
    private var isVpnBound = false
    
    private val vpnConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            vpnService = (service as? DeenGuardVpnService)
            isVpnBound = true
        }
        override fun onServiceDisconnected(name: ComponentName?) {
            vpnService = null
            isVpnBound = false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        startActivityForResult(intent, 0)
                        result.success(false)
                    } else {
                        onActivityResult(0, RESULT_OK, null)
                        result.success(true)
                    }
                }
                "stopVpn" -> {
                    val stopIntent = Intent(this, DeenGuardVpnService::class.java)
                    stopIntent.action = "STOP_VPN"
                    startService(stopIntent)
                    result.success(null)
                }
                "setFamilyProtection" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    DeenGuardVpnService.setFamilyProtection(enabled)
                    saveVpnSettings()
                    result.success(enabled)
                }
                "setBlocklistEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    DeenGuardVpnService.setBlocklistEnabledState(enabled)
                    saveVpnSettings()
                    result.success(enabled)
                }
                "injectBlocklist" -> {
                    val domains = call.argument<List<String>>("domains") ?: emptyList()
                    DeenGuardVpnService.injectBlocklist(domains)
                    result.success(domains.size)
                }
                "getBlocklistSize" -> {
                    result.success(DeenGuardVpnService.getBlocklistSize())
                }
                "getFamilyProtection" -> {
                    result.success(DeenGuardVpnService.isFamilyProtectionEnabled)
                }
                "getBlocklistEnabled" -> {
                    result.success(DeenGuardVpnService.isBlocklistEnabled)
                }
                "loadBlocklistFromAssets" -> {
                    val filename = call.argument<String>("filename") ?: "blocklist.txt"
                    DeenGuardVpnService.injectBlocklistFromAssets(this, filename)
                    result.success(DeenGuardVpnService.getBlocklistSize())
                }
                else -> result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AD_SKIP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdSkipService" -> {
                    if (checkMyAccessibilityServiceEnabled(DeenGuardAdSkipService::class.java)) {
                        DeenGuardAdSkipService.setEnabled(true)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stopAdSkipService" -> {
                    DeenGuardAdSkipService.setEnabled(false)
                    result.success(true)
                }
                "isAdSkipEnabled" -> {
                    result.success(DeenGuardAdSkipService.isServiceEnabled)
                }
                "isAdPlaying" -> {
                    result.success(DeenGuardAdSkipService.isAdPlaying)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "checkAccessibilityPermission" -> {
                    result.success(checkMyAccessibilityServiceEnabled(DeenGuardAdSkipService::class.java))
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun checkMyAccessibilityServiceEnabled(serviceClass: Class<*>): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        
        val componentName = ComponentName(this, serviceClass).flattenToString()
        return enabledServices.contains(componentName)
    }
    
    private fun saveVpnSettings() {
        val prefs = getSharedPreferences("deenguard_vpn_prefs", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("family_protection_enabled", DeenGuardVpnService.isFamilyProtectionEnabled)
            .putBoolean("blocklist_enabled", DeenGuardVpnService.isBlocklistEnabled)
            .apply()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 0 && resultCode == RESULT_OK) {
            val startIntent = Intent(this, DeenGuardVpnService::class.java)
            startService(startIntent)
        }
    }
    
    override fun onStart() {
        super.onStart()
        val intent = Intent(this, DeenGuardVpnService::class.java)
        bindService(intent, vpnConnection, Context.BIND_AUTO_CREATE)
    }
    
    override fun onStop() {
        super.onStop()
        if (isVpnBound) {
            unbindService(vpnConnection)
            isVpnBound = false
        }
    }
}
