package com.example.deenguard

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log

class DeenGuardVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_VPN") {
            Log.d("DeenGuardVPN", "Stop command received")
            stopVpn()
            return START_NOT_STICKY
        }

        Log.d("DeenGuardVPN", "VPN Service Started")
        
        try {
            vpnInterface?.close()
            
            val builder = Builder()

            // Assign a local internal IP to the VPN interface
            builder.addAddress("10.0.0.2", 32)

            // Split-tunnel approach:
            // Instead of routing 0.0.0.0/0 (which blackholes ALL traffic without a forwarder),
            // we route a single dummy IP. This bypasses the VPN for real internet traffic,
            // allowing apps to use Wi-Fi and Mobile Data normally.
            builder.addRoute("10.0.0.3", 32) 

            // We enforce a family-safe DNS that blocks adult content and ads.
            // Using AdGuard Family Protection DNS:
            builder.addDnsServer("94.140.14.15")
            builder.addDnsServer("94.140.15.16")

            // Set the session name
            builder.setSession("DeenGuard Protection")

            // Establish the VPN connection
            vpnInterface = builder.establish()
            Log.d("DeenGuardVPN", "VPN Interface Established for DNS filtering")
        } catch (e: Exception) {
            Log.e("DeenGuardVPN", "Error establishing VPN", e)
        }

        return START_STICKY
    }

    private fun stopVpn() {
        try {
            vpnInterface?.close()
            vpnInterface = null
            Log.d("DeenGuardVPN", "VPN Interface closed manually")
        } catch (e: Exception) {
            Log.e("DeenGuardVPN", "Error closing VPN interface", e)
        }
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("DeenGuardVPN", "VPN Service Destroyed")
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e("DeenGuardVPN", "Error closing VPN interface", e)
        }
    }
}
