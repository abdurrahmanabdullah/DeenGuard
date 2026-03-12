package com.deenguard.android.accessibility_service

import android.accessibilityservice.AccessibilityService
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class DeenGuardAdSkipService : AccessibilityService() {
    
    companion object {
        private const val TAG = "DeenGuardAdSkip"
        
        const val YOUTUBE_PACKAGE = "com.google.android.youtube"
        
        private val SKIP_BUTTON_RES_IDS = listOf(
            "com.google.android.youtube:id/menu_item_1",
            "com.google.android.youtube:id/skip_ad_button",
            "com.google.android.youtube:id/skip_ad",
            "com.google.android.youtube:id/end_card_skip_button",
            "com.google.android.youtube:id/polymer_bottom_sheet",
            "com.google.android.libraries.youtube.player.ui.SpipBottomSheet",
            "com.google.android.libraries.youtube.player.ui.EndScreenViewController"
        )
        
        private val AD_TEXT_PATTERNS = listOf(
            "Ad",
            "Sponsored",
            "Advertisement",
            "Watch this ad",
            "Ad will play in",
            "Skip ad in",
            "Skip"
        )
        
        @Volatile
        var isServiceEnabled = false
            private set
        
        @Volatile
        var isAdPlaying = false
            private set
        
        fun setEnabled(enabled: Boolean) {
            isServiceEnabled = enabled
        }
    }
    
    private var audioManager: AudioManager? = null
    private var originalMusicVolume: Int = -1
    private var wasMuted = false
    
    private var lastSkipAttemptTime: Long = 0
    private val skipCooldownMs = 1000L
    
    override fun onCreate() {
        super.onCreate()
        isServiceEnabled = true
        audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        Log.d(TAG, "DeenGuardAdSkipService created")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isServiceEnabled) return
        
        event ?: return
        
        val packageName = event.packageName?.toString() ?: return
        
        if (packageName != YOUTUBE_PACKAGE) return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED,
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                checkForAdContent(event)
                tryAutoSkipAd()
            }
        }
    }
    
    private fun checkForAdContent(event: AccessibilityEvent) {
        val textContent = event.text?.joinToString(" ") ?: ""
        val contentDescription = event.contentDescription?.toString() ?: ""
        val combinedContent = "$textContent $contentDescription".lowercase()
        
        val isAdCurrentlyPlaying = AD_TEXT_PATTERNS.any { pattern ->
            combinedContent.contains(pattern.lowercase())
        }
        
        if (isAdCurrentlyPlaying && !isAdPlaying) {
            isAdPlaying = true
            Log.d(TAG, "Ad detected - muting music")
            muteMusicStream()
        } else if (!isAdCurrentlyPlaying && isAdPlaying) {
            isAdPlaying = false
            Log.d(TAG, "Ad ended - restoring music")
            restoreMusicStream()
        }
    }
    
    private fun muteMusicStream() {
        try {
            audioManager ?: return
            
            if (originalMusicVolume == -1) {
                originalMusicVolume = audioManager?.getStreamVolume(AudioManager.STREAM_MUSIC) ?: 0
            }
            
            if (originalMusicVolume > 0) {
                wasMuted = true
                audioManager?.setStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    0,
                    0
                )
                Log.d(TAG, "Music stream muted")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Cannot mute - permission denied", e)
        }
    }
    
    private fun restoreMusicStream() {
        try {
            audioManager ?: return
            
            if (wasMuted && originalMusicVolume > 0) {
                audioManager?.setStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    originalMusicVolume,
                    0
                )
                wasMuted = false
                originalMusicVolume = -1
                Log.d(TAG, "Music stream restored")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Cannot restore - permission denied", e)
        }
    }
    
    private fun tryAutoSkipAd() {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastSkipAttemptTime < skipCooldownMs) {
            return
        }
        lastSkipAttemptTime = currentTime
        
        val skipButton = findSkipButton()
        if (skipButton != null) {
            Log.d(TAG, "Skip button found - clicking")
            skipButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            skipButton.recycle()
            
            try {
                val allViews = rootInActiveWindow
                allViews?.recycle()
            } catch (e: Exception) {
                Log.e(TAG, "Error after click", e)
            }
            return
        }
        
        val overlaySkipButton = findOverlaySkipButton()
        if (overlaySkipButton != null) {
            Log.d(TAG, "Overlay skip button found - clicking")
            overlaySkipButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            overlaySkipButton.recycle()
        }
    }
    
    private fun findSkipButton(): AccessibilityNodeInfo? {
        val rootNode = rootInActiveWindow ?: return null
        
        for (resId in SKIP_BUTTON_RES_IDS) {
            val buttons = rootNode.findAllAccessibilityViewsByTextId(resId)
            if (buttons.isNotEmpty()) {
                return buttons.first()
            }
        }
        
        val skipButton = findByText(listOf("Skip", "Skip Ad", "Skip ad", "SKIP"))
        rootNode.recycle()
        return skipButton
    }
    
    private fun findOverlaySkipButton(): AccessibilityNodeInfo? {
        val rootNode = rootInActiveWindow ?: return null
        
        val allNodes = mutableListOf<AccessibilityNodeInfo>()
        collectAllNodes(rootNode, allNodes)
        
        for (node in allNodes) {
            val text = node.text?.toString() ?: ""
            val contentDesc = node.contentDescription?.toString() ?: ""
            val viewId = node.viewIdResourceName ?: ""
            
            if ((text.contains("Skip", ignoreCase = true) || 
                 contentDesc.contains("Skip", ignoreCase = true) ||
                 viewId.contains("skip", ignoreCase = true)) &&
                node.isClickable) {
                
                val bounds = android.graphics.Rect()
                node.getBoundsInScreen(bounds)
                
                val displayMetrics = resources.displayMetrics
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels
                
                if (bounds.left in 0..screenWidth && bounds.top in 0..screenHeight) {
                    val result = node
                    for (n in allNodes) {
                        if (n != result) n.recycle()
                    }
                    rootNode.recycle()
                    return result
                }
            }
        }
        
        for (node in allNodes) {
            node.recycle()
        }
        rootNode.recycle()
        return null
    }
    
    private fun collectAllNodes(node: AccessibilityNodeInfo, list: MutableList<AccessibilityNodeInfo>) {
        list.add(node)
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            collectAllNodes(child, list)
        }
    }
    
    private fun findByText(texts: List<String>): AccessibilityNodeInfo? {
        val rootNode = rootInActiveWindow ?: return null
        
        val allNodes = mutableListOf<AccessibilityNodeInfo>()
        collectAllNodes(rootNode, allNodes)
        
        for (text in texts) {
            for (node in allNodes) {
                val nodeText = node.text?.toString() ?: ""
                val contentDesc = node.contentDescription?.toString() ?: ""
                
                if ((nodeText.equals(text, ignoreCase = true) ||
                     contentDesc.equals(text, ignoreCase = true)) &&
                    node.isClickable) {
                    
                    val result = node
                    for (n in allNodes) {
                        if (n != result) n.recycle()
                    }
                    rootNode.recycle()
                    return result
                }
            }
        }
        
        for (node in allNodes) {
            node.recycle()
        }
        rootNode.recycle()
        return null
    }
    
    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }
    
    override fun onDestroy() {
        isServiceEnabled = false
        restoreMusicStream()
        super.onDestroy()
        Log.d(TAG, "DeenGuardAdSkipService destroyed")
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = accessibilityServiceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_VIEW_SCROLLED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            notificationTimeout = 100
        }
        Log.d(TAG, "Accessibility service connected")
    }
}
