package com.boeko.minilauncher

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

class UsageMonitorService : Service() {
    
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var timeLimitMinutes: Int = 15
    private lateinit var prefs: SharedPreferences
    private val notifiedApps = mutableSetOf<String>()
    private val priorityApps = mutableSetOf<String>() // Apps to monitor
    
    companion object {
        const val EXTRA_TIME_LIMIT = "time_limit_minutes"
        const val EXTRA_PRIORITY_APPS = "priority_apps"
        const val CHANNEL_ID = "screen_timer_service"
        const val NOTIFICATION_ID = 1001
        private const val CHECK_INTERVAL = 30000L // 30 seconds
        
        private var isRunning = false
        
        fun isServiceRunning(): Boolean {
            return isRunning
        }
        
        /**
         * Reset notification tracking in SharedPreferences
         * Called when user sets a new time limit to allow fresh notifications
         */
        fun resetNotifications(context: Context) {
            val prefs = context.getSharedPreferences("minilauncher_usage", Context.MODE_PRIVATE)
            prefs.edit().putString("notified_apps", "").apply()
            android.util.Log.d("UsageMonitorService", "🔄 RESET: Cleared all notified apps from SharedPreferences")
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences("minilauncher_usage", Context.MODE_PRIVATE)
        loadNotifiedApps()
        createNotificationChannel()
        isRunning = true
        android.util.Log.d("UsageMonitorService", "✅ Service created")
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        timeLimitMinutes = intent?.getIntExtra(EXTRA_TIME_LIMIT, 15) ?: 15
        
        // Get priority apps list from intent
        val priorityAppsList = intent?.getStringArrayListExtra(EXTRA_PRIORITY_APPS)
        android.util.Log.d("UsageMonitorService", "========================================")
        android.util.Log.d("UsageMonitorService", "🎯 NATIVE PRIORITY APPS DEBUG:")
        if (priorityAppsList != null) {
            priorityApps.clear()
            priorityApps.addAll(priorityAppsList)
            android.util.Log.d("UsageMonitorService", "📱 Priority apps loaded: ${priorityApps.size} apps")
            priorityApps.forEachIndexed { index, app ->
                android.util.Log.d("UsageMonitorService", "  [$index] $app")
            }
        } else {
            android.util.Log.w("UsageMonitorService", "⚠️ No priority apps provided - will monitor ALL apps")
        }
        android.util.Log.d("UsageMonitorService", "========================================")

        
        android.util.Log.d("UsageMonitorService", "⏱️ Time limit set to: $timeLimitMinutes minutes")
        
        // 🔄 SMART RESET: Clear in-memory notified apps when starting with new limit
        // This ensures users get fresh notifications for the new time limit
        val oldCount = notifiedApps.size
        notifiedApps.clear()
        android.util.Log.d("UsageMonitorService", "🔄 RESET: Cleared $oldCount in-memory notified apps for new time limit")
        
        // Start as foreground service
        startForeground(NOTIFICATION_ID, createForegroundNotification())
        
        // Start monitoring
        startMonitoring()
        
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopMonitoring()
        isRunning = false
        android.util.Log.d("UsageMonitorService", "❌ Service destroyed")
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Create channel for foreground service (low importance)
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Screen Timer Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors app usage in background"
            }
            
            // Create channel for screen time alerts (high importance)
            val alertChannel = NotificationChannel(
                "screen_timer_alerts",
                "Screen Time Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alerts when you exceed screen time limits"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
                setShowBadge(true)
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
            manager.createNotificationChannel(alertChannel)
            
            android.util.Log.d("UsageMonitorService", "📢 Notification channels created")
        }
    }
    
    private fun createForegroundNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Timer Active")
            .setContentText("Monitoring app usage (Limit: $timeLimitMinutes min)")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun startMonitoring() {
        android.util.Log.d("UsageMonitorService", "🚀 Starting monitoring loop")
        
        monitoringRunnable = object : Runnable {
            override fun run() {
                checkAppUsage()
                handler.postDelayed(this, CHECK_INTERVAL)
            }
        }
        handler.post(monitoringRunnable!!)
    }
    
    private fun stopMonitoring() {
        monitoringRunnable?.let {
            handler.removeCallbacks(it)
            android.util.Log.d("UsageMonitorService", "⏹️ Monitoring stopped")
        }
        monitoringRunnable = null
    }
    
    private fun checkAppUsage() {
        try {
            // Check if it's a new day - reset notified apps
            if (shouldResetDaily()) {
                val oldCount = notifiedApps.size
                notifiedApps.clear()
                saveNotifiedApps()
                saveLastResetDate()
                android.util.Log.d("UsageMonitorService", "🔄 New day detected - reset $oldCount notified apps")
            }
            
            // Get current foreground app
            val currentApp = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                UsageStatsHelper.getCurrentForegroundApp(this)
            } else {
                null
            }
            
            if (currentApp == null) {
                // No app detected or unable to get foreground app
                return
            }
            
            // Skip our own app (launcher)
            if (currentApp == packageName) {
                return
            }
            
            // 🎯 FILTER: Only monitor priority apps (if list provided)
            if (priorityApps.isNotEmpty()) {
                if (!priorityApps.contains(currentApp)) {
                    android.util.Log.d("UsageMonitorService", "⏭️ SKIP: $currentApp NOT in priority list")
                    android.util.Log.d("UsageMonitorService", "   Priority list has ${priorityApps.size} apps: $priorityApps")
                    return
                } else {
                    android.util.Log.d("UsageMonitorService", "✅ CHECK: $currentApp IS in priority list")
                }
            } else {
                android.util.Log.w("UsageMonitorService", "⚠️ Priority list is empty - checking all apps")
            }
            
            // Check usage time for this app today
            val usageMinutes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                UsageStatsHelper.getAppUsageToday(this, currentApp)
            } else {
                0
            }
            
            // Get app name for better logging
            val appName = try {
                val packageManager = this.packageManager
                val appInfo = packageManager.getApplicationInfo(currentApp, 0)
                packageManager.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                currentApp
            }
            
            android.util.Log.d("UsageMonitorService", 
                "📱 Current: $appName | Usage: $usageMinutes min | Limit: $timeLimitMinutes min | Already notified: ${notifiedApps.contains(currentApp)}")
            
            // Check if limit is exceeded and not already notified
            if (usageMinutes >= timeLimitMinutes && !notifiedApps.contains(currentApp)) {
                val timeText = formatTimeForNotification(usageMinutes)
                android.util.Log.d("UsageMonitorService", "🚨 LIMIT REACHED for $appName ($timeText)")
                showLimitNotification(currentApp, usageMinutes)
                notifiedApps.add(currentApp)
                saveNotifiedApps()
                android.util.Log.d("UsageMonitorService", "✅ Notification sent and app marked as notified")
            }
        } catch (e: Exception) {
            android.util.Log.e("UsageMonitorService", "❌ Error checking usage: ${e.message}")
            e.printStackTrace()
        }
    }
    
    private fun formatTimeForNotification(minutes: Int): String {
        return when {
            minutes < 60 -> "$minutes minutes"
            minutes % 60 == 0 -> {
                val hours = minutes / 60
                if (hours == 1) "1 hour" else "$hours hours"
            }
            else -> {
                val hours = minutes / 60
                val remainingMinutes = minutes % 60
                val hourText = if (hours == 1) "1 hour" else "$hours hours"
                "$hourText $remainingMinutes minutes"
            }
        }
    }
    
    private fun showLimitNotification(packageName: String, minutes: Int) {
        try {
            val packageManager = this.packageManager
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val appName = packageManager.getApplicationLabel(appInfo).toString()
            
            // Format time display
            val timeText = formatTimeForNotification(minutes)
            
            // Create intent to open app and show dialog
            val notificationIntent = Intent(this, MainActivity::class.java)
            notificationIntent.putExtra("show_usage_dialog", true)
            notificationIntent.putExtra("app_name", appName)
            notificationIntent.putExtra("usage_minutes", minutes)
            notificationIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            
            val pendingIntent = PendingIntent.getActivity(
                this,
                packageName.hashCode(),
                notificationIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            
            val notification = NotificationCompat.Builder(this, "screen_timer_alerts")
                .setContentTitle("⏰ Screen Time Alert")
                .setContentText("You've used $appName for $timeText")
                .setSmallIcon(android.R.drawable.ic_dialog_alert)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setVibrate(longArrayOf(0, 250, 250, 250)) // Vibration pattern
                .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_LIGHTS)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setStyle(NotificationCompat.BigTextStyle()
                    .bigText("You've used $appName for $timeText today. Consider taking a break!"))
                .build()
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(packageName.hashCode() + 1000, notification) // Different ID from foreground notification
            
            android.util.Log.d("UsageMonitorService", "📬 Notification shown for $appName (ID: ${packageName.hashCode() + 1000})")
        } catch (e: Exception) {
            android.util.Log.e("UsageMonitorService", "❌ Error showing notification: ${e.message}")
            e.printStackTrace()
        }
    }
    
    private fun shouldResetDaily(): Boolean {
        val lastReset = prefs.getString("last_reset_date", null) ?: return true
        val today = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
            .format(java.util.Date())
        return lastReset != today
    }
    
    private fun saveLastResetDate() {
        val today = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
            .format(java.util.Date())
        prefs.edit().putString("last_reset_date", today).apply()
    }
    
    private fun loadNotifiedApps() {
        val notifiedAppsString = prefs.getString("notified_apps", "") ?: ""
        if (notifiedAppsString.isNotEmpty()) {
            notifiedApps.addAll(notifiedAppsString.split(","))
            android.util.Log.d("UsageMonitorService", "📋 Loaded ${notifiedApps.size} notified apps: $notifiedApps")
        } else {
            android.util.Log.d("UsageMonitorService", "📋 No previously notified apps")
        }
    }
    
    private fun saveNotifiedApps() {
        val notifiedAppsString = notifiedApps.joinToString(",")
        prefs.edit().putString("notified_apps", notifiedAppsString).apply()
        android.util.Log.d("UsageMonitorService", "💾 Saved notified apps: $notifiedAppsString")
    }
}