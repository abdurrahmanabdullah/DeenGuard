package com.walton.deenguard

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.walton.deenguard/vpn"
    private val AD_SKIP_CHANNEL = "com.walton.deenguard/adskip"
    private val APP_BLOCK_CHANNEL = "com.walton.deenguard/appblock"
    
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
                "checkVpnStatus" -> {
                    result.success(DeenGuardVpnService.isVpnRunning)
                }
                "restartVpn" -> {
                    try {
                        val intent = Intent(this, DeenGuardVpnService::class.java)
                        startService(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error restarting VPN", e)
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AD_SKIP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdSkipService" -> {
                    if (checkMyAccessibilityServiceEnabled(DeenGuardAccessibilityService::class.java)) {
                        DeenGuardAccessibilityService.setAdSkipEnabled(true)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stopAdSkipService" -> {
                    DeenGuardAccessibilityService.setAdSkipEnabled(false)
                    result.success(true)
                }
                "isAdSkipEnabled" -> {
                    result.success(DeenGuardAccessibilityService.isAdSkipEnabled)
                }
                "isAdPlaying" -> {
                    result.success(DeenGuardAccessibilityService.isAdPlaying)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "checkAccessibilityPermission" -> {
                    result.success(checkMyAccessibilityServiceEnabled(DeenGuardAccessibilityService::class.java))
                }
                "checkAppBlockPermission" -> {
                    result.success(checkMyAccessibilityServiceEnabled(DeenGuardAccessibilityService::class.java))
                }
                "openAppBlockSettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "openPrivateDnsSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_BLOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateAppBlockingSettings" -> {
                    Log.d("MainActivity", "updateAppBlockingSettings called")
                    val fbAppBlocked = call.argument<Boolean>("fb_app_blocked") ?: false
                    val fbReelsBlocked = call.argument<Boolean>("fb_reels_blocked") ?: false
                    val ytAppBlocked = call.argument<Boolean>("yt_app_blocked") ?: false
                    val ytShortsBlocked = call.argument<Boolean>("yt_shorts_blocked") ?: false
                    val igAppBlocked = call.argument<Boolean>("ig_app_blocked") ?: false
                    val igReelsBlocked = call.argument<Boolean>("ig_reels_blocked") ?: false

                    Log.d("MainActivity", "fbAppBlocked=$fbAppBlocked, fbReelsBlocked=$fbReelsBlocked")

                    val prefs = getSharedPreferences("deenguard_app_prefs", Context.MODE_PRIVATE)
                    prefs.edit()
                        .putBoolean("fb_app_blocked", fbAppBlocked)
                        .putBoolean("fb_reels_blocked", fbReelsBlocked)
                        .putBoolean("yt_app_blocked", ytAppBlocked)
                        .putBoolean("yt_shorts_blocked", ytShortsBlocked)
                        .putBoolean("ig_app_blocked", igAppBlocked)
                        .putBoolean("ig_reels_blocked", igReelsBlocked)
                        .apply()

                    Log.d("MainActivity", "Settings saved to SharedPreferences")
                    
                    // Reload settings in DeenGuardAccessibilityService
                    DeenGuardAccessibilityService.reloadFromPrefs(this)
                    
                    result.success(true)
                }
                "checkAppBlockPermission" -> {
                    Log.d("MainActivity", "checkAppBlockPermission called")
                    result.success(checkMyAccessibilityServiceEnabled(DeenGuardAccessibilityService::class.java))
                }
                "openAppBlockSettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "openPrivateDnsSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "getBlockedCount" -> {
                    val prefs = getSharedPreferences("deenguard_app_prefs", Context.MODE_PRIVATE)
                    result.success(prefs.getInt("total_harmful_blocked", 0))
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
