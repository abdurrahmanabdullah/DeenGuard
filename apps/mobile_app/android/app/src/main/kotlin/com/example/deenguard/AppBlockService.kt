package com.example.deenguard

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockService : AccessibilityService() {
    private val TAG = "AppBlockService"
    
    companion object {
        const val ACTION_START = "com.deenguard.START_BLOCKING"
        const val ACTION_STOP = "com.deenguard.STOP_BLOCKING"
        
        private val BLOCKED_PACKAGES = setOf(
            "com.example.blockedapp",
            "com.adult.app",
            "com.harmful.content"
        )
        
        var isServiceRunning = false
            private set
        
        private var blockedPackages = BLOCKED_PACKAGES.toMutableSet()
        
        fun updateBlockedPackages(packages: Set<String>) {
            blockedPackages = packages.toMutableSet()
        }
    }

    override fun onCreate() {
        super.onCreate()
        isServiceRunning = true
        Log.d(TAG, "AppBlockService created")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                val packageName = event.packageName?.toString() ?: return
                
                if (blockedPackages.contains(packageName)) {
                    Log.d(TAG, "Blocked app detected: $packageName")
                    showBlockScreen()
                }
                
                if (packageName == "com.instagram.android" || 
                    packageName == "com.twitter.android" ||
                    packageName == "com.facebook.katana" ||
                    packageName == "com.zhiliaoapp.musically") {
                    checkForInappropriateContent(event)
                }
            }
        }
    }

    private fun checkForInappropriateContent(event: AccessibilityEvent) {
        val content = event.text?.joinToString(" ") ?: ""
        val contentDescription = event.contentDescription?.toString() ?: ""
        
        val combinedContent = "$content $contentDescription"
        
        if (ReelDetector.isInappropriateContent(combinedContent)) {
            Log.d(TAG, "Inappropriate content detected")
            showBlockScreen()
        }
    }

    private fun showBlockScreen() {
        val intent = Intent(this, BlockedActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }

    override fun onDestroy() {
        isServiceRunning = false
        super.onDestroy()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility service connected")
    }
}
