package com.walton.deenguard

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.media.AudioManager
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class DeenGuardAccessibilityService : AccessibilityService() {

    private val TAG = "DeenGuardAccessibility"

    companion object {
        const val TAG_STATIC = "DeenGuardAccessibility"
        
        // App Blocking Constants
        const val ACTION_START = "com.walton.deenguard.START_BLOCKING"
        const val ACTION_STOP = "com.walton.deenguard.STOP_BLOCKING"
        
        private const val PREFS_NAME = "deenguard_app_prefs"
        private const val KEY_FB_APP_BLOCKED = "fb_app_blocked"
        private const val KEY_FB_REELS_BLOCKED = "fb_reels_blocked"
        private const val KEY_YT_APP_BLOCKED = "yt_app_blocked"
        private const val KEY_YT_SHORTS_BLOCKED = "yt_shorts_blocked"
        private const val KEY_IG_APP_BLOCKED = "ig_app_blocked"
        private const val KEY_IG_REELS_BLOCKED = "ig_reels_blocked"
        const val KEY_TOTAL_HARMFUL_BLOCKED = "total_harmful_blocked"

        // Usage Tracking Keys
        const val KEY_FB_USAGE_COUNT = "fb_usage_count"
        const val KEY_YT_USAGE_COUNT = "yt_usage_count"
        const val KEY_IG_USAGE_COUNT = "ig_usage_count"
        
        // Duration Tracking Keys (in milliseconds)
        const val KEY_FB_USAGE_DURATION = "fb_usage_duration"
        const val KEY_YT_USAGE_DURATION = "yt_usage_duration"
        const val KEY_IG_USAGE_DURATION = "ig_usage_duration"
        const val KEY_TOTAL_SCREEN_TIME = "total_screen_time"

        val DEFAULT_BLOCKED_PACKAGES = setOf(
            "com.example.blockedapp",
            "com.adult.app",
            "com.harmful.content"
        )

        val FACEBOOK_PACKAGES = setOf(
            "com.facebook.katana",
            "com.facebook.orca",
            "com.facebook.mlite",
            "com.facebook.lite",
            "com.facebook.messenger",
            "com.facebook.msys.messenger"
        )

        val YOUTUBE_PACKAGES = setOf(
            "com.google.android.youtube",
            "com.google.android.apps.youtube.music"
        )

        val INSTAGRAM_PACKAGES = setOf(
            "com.instagram.android",
            "com.instagram.lite"
        )

        val REELS_PACKAGES = setOf(
            "com.instagram.android",
            "com.instagram.lite",
            "com.facebook.katana",
            "com.facebook.lite",
            "com.zhiliaoapp.musically",
            "com.google.android.youtube"
        )
        
        var isServiceRunning = false
            private set
        
        private var blockedPackages = DEFAULT_BLOCKED_PACKAGES.toMutableSet()
        private var lastBlockedTime = 0L
        private const val BLOCK_COOLDOWN = 500L // Reduced to 500ms for responsiveness

        // Ad Skipping Constants
        const val YOUTUBE_PACKAGE = "com.google.android.youtube"
        private val AD_TEXT_PATTERNS = listOf(
            "Ad", "Sponsored", "Advertisement", "Watch this ad", 
            "Ad will play in", "Skip ad in", "Skip"
        )

        fun updateBlockedPackages(packages: Set<String>) {
            blockedPackages = packages.toMutableSet()
        }

        @Volatile
        var isAdSkipEnabled = true
            private set

        @Volatile
        var isAdPlaying = false
            internal set

        fun setAdSkipEnabled(enabled: Boolean) {
            isAdSkipEnabled = enabled
        }

        fun reloadFromPrefs(context: Context) {
            Log.d(TAG_STATIC, "Reloading settings from prefs")
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            loadBlockedAppsStatic(prefs)
        }

        private fun loadBlockedAppsStatic(prefs: SharedPreferences) {
            val fbAppBlocked = prefs.getBoolean(KEY_FB_APP_BLOCKED, false)
            val ytAppBlocked = prefs.getBoolean(KEY_YT_APP_BLOCKED, false)
            val igAppBlocked = prefs.getBoolean(KEY_IG_APP_BLOCKED, false)

            blockedPackages.clear()
            blockedPackages.addAll(DEFAULT_BLOCKED_PACKAGES)

            if (fbAppBlocked) blockedPackages.addAll(FACEBOOK_PACKAGES)
            if (ytAppBlocked) blockedPackages.addAll(YOUTUBE_PACKAGES)
            if (igAppBlocked) blockedPackages.addAll(INSTAGRAM_PACKAGES)

            Log.d(TAG_STATIC, "Settings loaded - blocked apps: $blockedPackages")
        }
    }

    private lateinit var prefs: SharedPreferences
    private var lastActivePackage: String? = null
    private var lastActiveStartTime: Long = 0L
    private var lastBlockedPackage: String? = null
    
    // Ad Skipping fields
    private var audioManager: AudioManager? = null
    private var originalMusicVolume: Int = -1
    private var wasMuted = false
    private var lastSkipAttemptTime: Long = 0
    private val skipCooldownMs = 1000L

    override fun onCreate() {
        super.onCreate()
        isServiceRunning = true
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        loadBlockedApps()
        Log.d(TAG, "DeenGuardAccessibilityService created")
    }

    private fun loadBlockedApps() {
        val fbAppBlocked = prefs.getBoolean(KEY_FB_APP_BLOCKED, false)
        val ytAppBlocked = prefs.getBoolean(KEY_YT_APP_BLOCKED, false)
        val igAppBlocked = prefs.getBoolean(KEY_IG_APP_BLOCKED, false)

        blockedPackages.clear()
        blockedPackages.addAll(DEFAULT_BLOCKED_PACKAGES)

        if (fbAppBlocked) blockedPackages.addAll(FACEBOOK_PACKAGES)
        if (ytAppBlocked) blockedPackages.addAll(YOUTUBE_PACKAGES)
        if (igAppBlocked) blockedPackages.addAll(INSTAGRAM_PACKAGES)

        Log.d(TAG, "Loaded blocked apps: $blockedPackages")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val packageName = event.packageName?.toString() ?: return

        // 1. App Blocking Logic
        handleAppBlocking(event, packageName)

        // 2. Ad Skipping Logic (YouTube only)
        if (packageName == YOUTUBE_PACKAGE) {
            handleAdSkipping(event)
        }

        // 3. Usage Tracking Logic
        handleUsageTracking(event, packageName)
    }

    private fun handleUsageTracking(event: AccessibilityEvent, packageName: String) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val currentTime = System.currentTimeMillis()
            
            // If we are leaving a tracked app, record its duration
            if (lastActivePackage != null && lastActivePackage != packageName) {
                recordDuration(lastActivePackage!!, currentTime - lastActiveStartTime)
            }

            if (packageName != lastActivePackage && packageName != "com.walton.deenguard") {
                lastActivePackage = packageName
                lastActiveStartTime = currentTime
                
                val countKey = when {
                    FACEBOOK_PACKAGES.contains(packageName) -> KEY_FB_USAGE_COUNT
                    YOUTUBE_PACKAGES.contains(packageName) -> KEY_YT_USAGE_COUNT
                    INSTAGRAM_PACKAGES.contains(packageName) -> KEY_IG_USAGE_COUNT
                    else -> null
                }
                
                countKey?.let {
                    val currentCount = prefs.getInt(it, 0)
                    prefs.edit().putInt(it, currentCount + 1).apply()
                    Log.d(TAG, "Launched $packageName, count: ${currentCount + 1}")
                }
            } else if (packageName == "com.walton.deenguard") {
                // If user returns to our app, clear lastActivePackage so we don't track our own time
                lastActivePackage = null
            }
        }
    }

    private fun recordDuration(packageName: String, durationMs: Long) {
        if (durationMs <= 0) return
        
        val durationKey = when {
            FACEBOOK_PACKAGES.contains(packageName) -> KEY_FB_USAGE_DURATION
            YOUTUBE_PACKAGES.contains(packageName) -> KEY_YT_USAGE_DURATION
            INSTAGRAM_PACKAGES.contains(packageName) -> KEY_IG_USAGE_DURATION
            else -> null
        }
        
        val editor = prefs.edit()
        
        // Track app-specific duration
        durationKey?.let {
            val currentDuration = prefs.getLong(it, 0L)
            editor.putLong(it, currentDuration + durationMs)
            Log.d(TAG, "Added $durationMs ms to $packageName duration")
        }
        
        // Track total system-wide screen time (only for apps we are interested in or all apps?)
        // The user screenshot shows "Today's 2h 52m" as total time. 
        // We'll track total time spent in any foreground app (excluding system UI if possible)
        if (packageName != "com.android.systemui") {
            val totalTime = prefs.getLong(KEY_TOTAL_SCREEN_TIME, 0L)
            editor.putLong(KEY_TOTAL_SCREEN_TIME, totalTime + durationMs)
        }
        
        editor.apply()
    }

    private fun handleAppBlocking(event: AccessibilityEvent, packageName: String) {
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                if (blockedPackages.contains(packageName)) {
                    val currentTime = System.currentTimeMillis()
                    if (packageName != lastBlockedPackage || currentTime - lastBlockedTime > BLOCK_COOLDOWN) {
                        Log.d(TAG, "Blocked app detected: $packageName")
                        lastBlockedPackage = packageName
                        lastBlockedTime = currentTime
                        
                        // Increment count for app blocking too
                        val currentCount = prefs.getInt(KEY_TOTAL_HARMFUL_BLOCKED, 0)
                        prefs.edit().putInt(KEY_TOTAL_HARMFUL_BLOCKED, currentCount + 1).apply()
                        
                        showBlockScreen()
                    }
                }
                
                if (REELS_PACKAGES.contains(packageName)) {
                    handleReelsBlocking(event, packageName)
                }
            }
        }
    }

    private fun handleAdSkipping(event: AccessibilityEvent) {
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
                audioManager?.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
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
                audioManager?.setStreamVolume(AudioManager.STREAM_MUSIC, originalMusicVolume, 0)
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
        if (currentTime - lastSkipAttemptTime < skipCooldownMs) return
        lastSkipAttemptTime = currentTime
        
        val skipButton = findSkipButton()
        if (skipButton != null) {
            Log.d(TAG, "Skip button found - clicking")
            skipButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            skipButton.recycle()
            return
        }
    }

    private fun findSkipButton(): AccessibilityNodeInfo? {
        val rootNode = rootInActiveWindow ?: return null
        val skipButton = findByText(listOf("Skip", "Skip Ad", "Skip ad", "SKIP"))
        rootNode.recycle()
        return skipButton
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
                    allNodes.forEach { if (it != result) it.recycle() }
                    rootNode.recycle()
                    return result
                }
            }
        }
        allNodes.forEach { it.recycle() }
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

    private fun handleReelsBlocking(event: AccessibilityEvent, packageName: String) {
        val fbReelsBlocked = prefs.getBoolean(KEY_FB_REELS_BLOCKED, false)
        val ytShortsBlocked = prefs.getBoolean(KEY_YT_SHORTS_BLOCKED, false)
        val igReelsBlocked = prefs.getBoolean(KEY_IG_REELS_BLOCKED, false)

        // Don't block if the entire app is already blocked
        if (blockedPackages.contains(packageName)) return
        
        val content = event.text?.joinToString(" ") ?: ""
        val contentDescription = event.contentDescription?.toString() ?: ""
        val combinedContent = "$content $contentDescription"
        
        // Block if it's a Reels screen OR if it contains inappropriate content
        val isReel = ReelDetector.isReelScreen(combinedContent)
        val isInappropriate = ReelDetector.isInappropriateContent(combinedContent)

        if (isReel || isInappropriate) {
            val currentTime = System.currentTimeMillis()
            if (packageName != lastBlockedPackage || currentTime - lastBlockedTime > BLOCK_COOLDOWN) {
                when (packageName) {
                    "com.facebook.katana" -> if (fbReelsBlocked || isInappropriate) blockWithLogging("Facebook Reel/Short")
                    "com.google.android.youtube" -> if (ytShortsBlocked || isInappropriate) blockWithLogging("YouTube Short")
                    "com.instagram.android" -> if (igReelsBlocked || isInappropriate) blockWithLogging("Instagram Reel")
                }
            }
        }
    }

    private fun blockWithLogging(type: String) {
        Log.d(TAG, "$type detected and blocked")
        lastBlockedTime = System.currentTimeMillis()
        
        // Increment the total harmful blocked count
        val currentCount = prefs.getInt(KEY_TOTAL_HARMFUL_BLOCKED, 0)
        prefs.edit().putInt(KEY_TOTAL_HARMFUL_BLOCKED, currentCount + 1).apply()
        
        showBlockScreen()
    }

    private fun showBlockScreen() {
        // 1. Immediately minimize the blocked app by going to Home
        performGlobalAction(GLOBAL_ACTION_HOME)
        
        // 2. Launch the BlockedActivity to inform the user
        val intent = Intent(this, BlockedActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                     Intent.FLAG_ACTIVITY_CLEAR_TOP or 
                     Intent.FLAG_ACTIVITY_SINGLE_TOP or
                     Intent.FLAG_ACTIVITY_NO_ANIMATION)
        }
        try {
            startActivity(intent)
            Log.d(TAG, "BlockedActivity started after Home ejection")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting BlockedActivity", e)
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }

    override fun onDestroy() {
        isServiceRunning = false
        restoreMusicStream()
        super.onDestroy()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility service connected")
    }
}
