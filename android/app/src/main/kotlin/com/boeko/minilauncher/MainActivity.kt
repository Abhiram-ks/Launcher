package com.boeko.minilauncher

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.PowerManager
import android.view.WindowManager
import android.app.KeyguardManager
import android.content.Context
import android.app.admin.DevicePolicyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.os.Build

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "launcher_service"
    private val SCREEN_CONTROL_CHANNEL = "screen_control_service"
    private val USAGE_CHANNEL = "app_usage_service"
    private var isTurningOffScreen = false
    private var lastTurnOffTime = 0L
    
    companion object {
        private const val NOTIFICATION_PERMISSION_CODE = 1001
    }

    // ADD: MethodChannel for dialog communication
    private var dialogChannel: MethodChannel? = null

    private fun getDeviceAdminComponent(): ComponentName {
        return ComponentName(this, LauncherDeviceAdminReceiver::class.java)
    }
    
    private fun isDeviceAdminEnabled(): Boolean {
        return try {
            val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val component = getDeviceAdminComponent()
            val isActive = devicePolicyManager.isAdminActive(component)
            if (isActive) {
                // Double-check that it has lock screen permission
                val policies = devicePolicyManager.getActiveAdmins()
                android.util.Log.d("MainActivity", "Device admin active: $isActive, active admins: ${policies?.size}")
            }
            isActive
        } catch (e: Exception) {
            android.util.Log.w("MainActivity", "Error checking device admin: ${e.message}")
            false
        }
    }
    
    private fun requestDeviceAdmin() {
        if (!isDeviceAdminEnabled()) {
            val intent = Intent(android.app.admin.DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(android.app.admin.DevicePolicyManager.EXTRA_DEVICE_ADMIN, getDeviceAdminComponent())
            intent.putExtra(android.app.admin.DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Device admin permission is required to lock the screen reliably.")
            startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable flags for launcher functionality (but not FLAG_TURN_SCREEN_ON to avoid auto-wake)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
        
        handleLauncherIntent()

        // ADD: Handle notification tap to show dialog
        handleUsageNotification(intent)        
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLauncherIntent()

        // ADD: Handle notification tap when app is already open
        handleUsageNotification(intent)
    }

    // ADD: New method to handle usage notification taps
    private fun handleUsageNotification(intent: Intent?) {
        if (intent == null) return
        
        val showDialog = intent.getBooleanExtra("show_usage_dialog", false)
        if (showDialog) {
            val appName = intent.getStringExtra("app_name") ?: return
            val usageMinutes = intent.getIntExtra("usage_minutes", 0)
            
            // Wait a bit for Flutter engine to be ready
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                dialogChannel?.invokeMethod("showUsageDialog", mapOf(
                    "appName" to appName,
                    "minutes" to usageMinutes
                ))
            }, 500)
            
            // Clear the intent extras to prevent re-showing on rotation
            intent.removeExtra("show_usage_dialog")
            intent.removeExtra("app_name")
            intent.removeExtra("usage_minutes")
        }
    }

    private fun handleLauncherIntent() {
        val intent = intent
        if (intent != null) {
            val action = intent.action
            val categories = intent.categories

            // Check if this is a home button press or launcher intent
            if (Intent.ACTION_MAIN == action &&
                (categories?.contains(Intent.CATEGORY_HOME) == true ||
                        categories?.contains(Intent.CATEGORY_LAUNCHER) == true)) {

                // Clear any existing task flags and bring to front
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

                // Ensure we're the main activity
                moveTaskToFront()
            }
        }
    }

    private fun moveTaskToFront() {
        // Bring the app to foreground
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ADD: Setup dialog channel
        dialogChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "usage_dialog_channel")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAsDefaultLauncher" -> {
                    setAsDefaultLauncher()
                    result.success(null)
                }
                "checkDefaultLauncher" -> {
                    val isDefault = isDefaultLauncher()
                    result.success(isDefault)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "turnOffScreen" -> {
                    val success = turnOffScreen()
                    result.success(success)
                }
                "turnOnScreen" -> {
                    val success = turnOnScreen()
                    result.success(success)
                }
                "isScreenOn" -> {
                    val isOn = isScreenOn()
                    result.success(isOn)
                }
                "requestDeviceAdmin" -> {
                    requestDeviceAdmin()
                    result.success(null)
                }
                "isDeviceAdminEnabled" -> {
                    val isEnabled = isDeviceAdminEnabled()
                    result.success(isEnabled)
                }
                "openAccessibilitySettings" -> {
                    try {
                        startActivity(Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        })
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("OPEN_SETTINGS_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestUsagePermission" -> {
                    UsageStatsHelper.requestUsagePermission(this)
                    result.success(null)
                }
                "hasUsagePermission" -> {
                    val hasPermission = UsageStatsHelper.hasUsagePermission(this)
                    result.success(hasPermission)
                }
                "getAppUsage" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        val usageData = UsageStatsHelper.getAppUsage(this, startTime, endTime)
                        result.success(usageData)
                    } else {
                        result.success(emptyList<Map<String, Any>>())
                    }
                }
                "startMonitoring" -> {
                    android.util.Log.d("MainActivity", "========================================")
                    android.util.Log.d("MainActivity", "🎯 MAINACTIVITY DEBUG:")
                    
                    val timeLimitMinutes = call.argument<Int>("timeLimitMinutes") ?: 15
                    android.util.Log.d("MainActivity", "⏱️ Time limit: $timeLimitMinutes")
                    
                    val priorityApps = call.argument<List<String>>("priorityApps")
                    android.util.Log.d("MainActivity", "📱 Received priority apps: ${priorityApps?.size ?: 0}")
                    
                    if (priorityApps != null) {
                        priorityApps.forEachIndexed { index, app ->
                            android.util.Log.d("MainActivity", "  [$index] $app")
                        }
                    } else {
                        android.util.Log.w("MainActivity", "⚠️ No priority apps received from Flutter")
                    }
                    
                    val serviceIntent = Intent(this, UsageMonitorService::class.java)
                    serviceIntent.putExtra(UsageMonitorService.EXTRA_TIME_LIMIT, timeLimitMinutes)
                    
                    if (priorityApps != null) {
                        val arrayList = ArrayList(priorityApps)
                        serviceIntent.putStringArrayListExtra(
                            UsageMonitorService.EXTRA_PRIORITY_APPS,
                            arrayList
                        )
                        android.util.Log.d("MainActivity", "✅ Added ${arrayList.size} apps to intent extras")
                    }
                    
                    android.util.Log.d("MainActivity", "🚀 Starting service...")
                    android.util.Log.d("MainActivity", "========================================")
                    
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(null)
                }
                "stopMonitoring" -> {
                    val serviceIntent = Intent(this, UsageMonitorService::class.java)
                    stopService(serviceIntent)
                    result.success(null)
                }
                "getCurrentForegroundApp" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        val foregroundApp = UsageStatsHelper.getCurrentForegroundApp(this)
                        result.success(foregroundApp)
                    } else {
                        result.success(null)
                    }
                }
                "isMonitoringRunning" -> {
                    val isRunning = UsageMonitorService.isServiceRunning()
                    result.success(isRunning)
                }
                "resetNotifications" -> {
                    UsageMonitorService.resetNotifications(this)
                    result.success(null)
                }
                "hasNotificationPermission" -> {
                    val hasPermission = hasNotificationPermission()
                    result.success(hasPermission)
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun hasNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true // Permission not needed for Android < 13
        }
    }
    
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                NOTIFICATION_PERMISSION_CODE
            )
        }
    }

    private fun setAsDefaultLauncher() {
        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
        startActivity(intent)
    }

    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)

        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    private fun turnOffScreen(): Boolean {
        // Prevent multiple simultaneous calls
        val currentTime = System.currentTimeMillis()
        if (isTurningOffScreen) {
            android.util.Log.d("MainActivity", "Screen turn off already in progress, ignoring")
            return false
        }
        
        // Debounce: prevent calls within 1 second
        if (currentTime - lastTurnOffTime < 1000) {
            android.util.Log.d("MainActivity", "Screen turn off called too soon, ignoring")
            return false
        }
        
        isTurningOffScreen = true
        lastTurnOffTime = currentTime
        
        return try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (powerManager.isInteractive) {
                // Clear screen-on flags before turning off to prevent immediate wake
                window.clearFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                
                // Method 1: Try DevicePolicyManager.lockNow() if device admin is enabled (MOST RELIABLE)
                val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                if (isDeviceAdminEnabled()) {
                    try {
                        android.util.Log.d("MainActivity", "Using DevicePolicyManager.lockNow()")
                        devicePolicyManager.lockNow()
                        android.util.Log.d("MainActivity", "lockNow() called successfully")
                        isTurningOffScreen = false
                        return true
                    } catch (e: SecurityException) {
                        android.util.Log.e("MainActivity", "lockNow() failed - device admin not properly enabled: ${e.message}")
                        // Device admin check was wrong or permission missing - request it
                        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                            requestDeviceAdmin()
                        }, 100)
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "lockNow() failed with error: ${e.message}")
                    }
                } else {
                    // Device admin not enabled - request it for better screen locking
                    android.util.Log.w("MainActivity", "Device admin not enabled - requesting permission")
                    // Request device admin in background thread to avoid blocking
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        requestDeviceAdmin()
                    }, 100)
                }
                
                // Method 2: Try to go to sleep using PowerManager (may not work without system permissions)
                // This is attempted even if device admin is not enabled, as it might work on some devices
                try {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        // Use reflection to call goToSleep (hidden API)
                        val method = powerManager.javaClass.getMethod("goToSleep", Long::class.java)
                        method.invoke(powerManager, System.currentTimeMillis())
                        android.util.Log.d("MainActivity", "goToSleep called successfully")
                        // Wait a bit to see if it worked
                        Thread.sleep(200)
                        // Check if screen is still on
                        if (!powerManager.isInteractive) {
                            android.util.Log.d("MainActivity", "Screen turned off successfully via goToSleep")
                            isTurningOffScreen = false
                            return true
                        } else {
                            android.util.Log.w("MainActivity", "goToSleep called but screen still on")
                        }
                    }
                } catch (e: Exception) {
                    android.util.Log.w("MainActivity", "goToSleep failed: ${e.message}")
                }
                
                // Method 3: Send screen off broadcast (may work on some devices)
                try {
                    val screenOffIntent = Intent(Intent.ACTION_SCREEN_OFF)
                    sendBroadcast(screenOffIntent)
                    android.util.Log.d("MainActivity", "Sent ACTION_SCREEN_OFF broadcast")
                    Thread.sleep(200)
                    if (!powerManager.isInteractive) {
                        android.util.Log.d("MainActivity", "Screen turned off via broadcast")
                        isTurningOffScreen = false
                        return true
                    }
                } catch (e: Exception) {
                    android.util.Log.w("MainActivity", "Screen off broadcast failed: ${e.message}")
                }
                
                // Method 4: Use KeyguardManager - lock the screen (at least locks it even if doesn't turn off)
                try {
                    val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                        if (!keyguardManager.isKeyguardLocked) {
                            // Try to lock keyguard
                            android.util.Log.d("MainActivity", "Attempting to lock keyguard")
                        }
                    }
                } catch (e: Exception) {
                    android.util.Log.w("MainActivity", "KeyguardManager approach failed: ${e.message}")
                }
                
                // Fallback: try AccessibilityService lock if enabled by user
                try {
                    if (LockAccessibilityService.tryLockScreen()) {
                        android.util.Log.d("MainActivity", "Locked via AccessibilityService")
                        isTurningOffScreen = false
                        return true
                    }
                } catch (_: Exception) { }

                // Do NOT move task to background, to avoid showing default launcher
                android.util.Log.w("MainActivity", "All methods failed - unable to turn off screen. Enable device admin or Accessibility Service for reliable screen locking.")
                isTurningOffScreen = false
                false
            } else {
                isTurningOffScreen = false
                true // Screen is already off
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "turnOffScreen error: ${e.message}")
            isTurningOffScreen = false
            false
        }
    }

    private fun turnOnScreen(): Boolean {
        return try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!powerManager.isInteractive) {
                // Use only WakeLock to turn on screen - no window flags
                val wakeLock = powerManager.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                    "MiniLauncher::WakeLock"
                )
                try {
                    wakeLock.acquire(1000) // Hold for 1 second
                } finally {
                    if (wakeLock.isHeld) {
                        wakeLock.release()
                    }
                }
                true
            } else {
                true // Screen is already on
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "turnOnScreen error: ${e.message}")
            false
        }
    }

    private fun isScreenOn(): Boolean {
        return try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.isInteractive
        } catch (e: Exception) {
            false
        }
    }
}