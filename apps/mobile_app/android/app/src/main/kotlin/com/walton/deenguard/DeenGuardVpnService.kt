package com.walton.deenguard

import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader

class DeenGuardVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null
    
    companion object {
        private const val TAG = "DeenGuardVPN"
        
        private val localBlocklist: HashSet<String> = hashSetOf()
        
        private const val PREFS_NAME = "deenguard_vpn_prefs"
        private const val KEY_FAMILY_PROTECTION = "family_protection_enabled"
        private const val KEY_BLOCKLIST_ENABLED = "blocklist_enabled"
        
        private const val DEFAULT_DNS_PRIMARY = "94.140.14.15"
        private const val DEFAULT_DNS_SECONDARY = "94.140.15.16"
        
        private const val CLEAN_DNS_PRIMARY = "94.140.14.14"
        private const val CLEAN_DNS_SECONDARY = "94.140.15.15"
        
        @Volatile
        var isFamilyProtectionEnabled = true
        
        @Volatile
        var isBlocklistEnabled = false
        
        fun injectBlocklist(domains: List<String>) {
            synchronized(localBlocklist) {
                localBlocklist.clear()
                localBlocklist.addAll(domains.map { it.lowercase().removePrefix("www.") })
                Log.d(TAG, "Blocklist injected with ${localBlocklist.size} domains")
            }
        }
        
        fun injectBlocklistFromAssets(context: Context, filename: String = "blocklist.txt") {
            try {
                val domains = mutableListOf<String>()
                context.assets.open(filename).bufferedReader().use { reader ->
                    reader.forEachLine { line ->
                        val trimmed = line.trim()
                        if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
                            domains.add(trimmed)
                        }
                    }
                }
                injectBlocklist(domains)
                Log.d(TAG, "Loaded ${domains.size} domains from assets")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading blocklist from assets", e)
            }
        }
        
        fun isDomainBlocked(domain: String): Boolean {
            if (!isBlocklistEnabled) return false
            
            val normalizedDomain = domain.lowercase().removePrefix("www.")
            
            synchronized(localBlocklist) {
                if (localBlocklist.contains(normalizedDomain)) {
                    return true
                }
                
                for (blockedDomain in localBlocklist) {
                    if (normalizedDomain.endsWith(".$blockedDomain")) {
                        return true
                    }
                }
                return false
            }
        }
        
        fun getBlocklistSize(): Int {
            synchronized(localBlocklist) {
                return localBlocklist.size
            }
        }
        
        fun clearBlocklist() {
            synchronized(localBlocklist) {
                localBlocklist.clear()
            }
        }
        
        fun setFamilyProtection(enabled: Boolean) {
            isFamilyProtectionEnabled = enabled
        }
        
        fun setBlocklistEnabledState(enabled: Boolean) {
            isBlocklistEnabled = enabled
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_VPN") {
            Log.d(TAG, "Stop command received")
            stopVpn()
            return START_NOT_STICKY
        }

        Log.d(TAG, "VPN Service Started")
        
        loadSettings()
        
        try {
            vpnInterface?.close()
            
            val builder = Builder()

            builder.addAddress("10.0.0.2", 32)

            builder.addRoute("10.0.0.3", 32) 

            val (primaryDns, secondaryDns) = if (isFamilyProtectionEnabled) {
                DEFAULT_DNS_PRIMARY to DEFAULT_DNS_SECONDARY
            } else {
                CLEAN_DNS_PRIMARY to CLEAN_DNS_SECONDARY
            }
            
            builder.addDnsServer(primaryDns)
            builder.addDnsServer(secondaryDns)

            builder.setSession("DeenGuard Protection")

            vpnInterface = builder.establish()
            Log.d(TAG, "VPN Interface Established - Family: $isFamilyProtectionEnabled, Blocklist: $isBlocklistEnabled")
        } catch (e: Exception) {
            Log.e(TAG, "Error establishing VPN", e)
        }

        return START_STICKY
    }
    
    private fun loadSettings() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        isFamilyProtectionEnabled = prefs.getBoolean(KEY_FAMILY_PROTECTION, true)
        isBlocklistEnabled = prefs.getBoolean(KEY_BLOCKLIST_ENABLED, false)
        Log.d(TAG, "Settings loaded - Family: $isFamilyProtectionEnabled, Blocklist: $isBlocklistEnabled")
    }

    private fun stopVpn() {
        try {
            vpnInterface?.close()
            vpnInterface = null
            Log.d(TAG, "VPN Interface closed manually")
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN interface", e)
        }
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "VPN Service Destroyed")
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN interface", e)
        }
    }
}
