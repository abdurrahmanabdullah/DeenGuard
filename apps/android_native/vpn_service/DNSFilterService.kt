package com.deenguard.android.vpn_service

import android.app.Service
import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream

class DNSFilterService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null
    private val TAG = "DNSFilterService"
    
    companion object {
        const val ACTION_START = "com.deenguard.START_VPN"
        const val ACTION_STOP = "com.deenguard.STOP_VPN"
        private val BLOCKED_DOMAINS = setOf(
            "example.com",
            "adult-domain.com",
            "harmful-site.com"
        )
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "DNSFilterService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startVpn()
            ACTION_STOP -> stopVpn()
        }
        return START_STICKY
    }

    private fun startVpn() {
        if (vpnInterface != null) {
            Log.d(TAG, "VPN already running")
            return
        }

        try {
            val builder = Builder()
                .setSession("DeenGuard VPN")
                .addAddress("10.0.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("8.8.8.8")
                .setMtu(1500)
                .establish()

            vpnInterface = builder
            Log.d(TAG, "VPN started successfully")
            
            Thread {
                processVpnTraffic()
            }.start()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start VPN: ${e.message}")
        }
    }

    private fun stopVpn() {
        try {
            vpnInterface?.close()
            vpnInterface = null
            Log.d(TAG, "VPN stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping VPN: ${e.message}")
        }
    }

    private fun processVpnTraffic() {
        val vpnFd = vpnInterface ?: return
        val inputStream = FileInputStream(vpnFd.fileDescriptor)
        val outputStream = FileOutputStream(vpnFd.fileDescriptor)
        
        val buffer = ByteArray(32767)
        
        try {
            while (vpnInterface != null) {
                val length = inputStream.read(buffer)
                if (length > 0) {
                    val packet = buffer.copyOf(length)
                    processPacket(packet, outputStream)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "VPN processing error: ${e.message}")
        }
    }

    private fun processPacket(packet: ByteArray, outputStream: FileOutputStream) {
        if (packet.size < 20) return
        
        val version = packet[0].toInt() shr 4
        if (version != 4) return
        
        val headerLength = (packet[0].toInt() and 0x0F) * 4
        if (packet.size < headerLength) return
        
        val protocol = packet[9].toInt()
        if (protocol != 17) return
        
        if (packet.size >= headerLength + 8) {
            val destPort = (packet[headerLength + 2].toInt() shl 8) or (packet[headerLength + 3].toInt() and 0xFF)
            if (destPort == 53) {
                Log.d(TAG, "DNS packet detected")
            }
        }
        
        outputStream.write(packet)
    }

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
    }
}
