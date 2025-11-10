package com.boeko.minilauncher

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import java.util.Calendar

object UsageStatsHelper {
    
    /**
     * Check if PACKAGE_USAGE_STATS permission is granted
     */
    fun hasUsagePermission(context: Context): Boolean {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            android.util.Log.e("UsageStatsHelper", "Error checking permission: ${e.message}")
            false
        }
    }
    
    /**
     * Request PACKAGE_USAGE_STATS permission by opening settings
     */
    fun requestUsagePermission(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }
    
    /**
     * Get app usage data for a time range
     * Returns list of maps with app info
     */
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getAppUsage(context: Context, startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsagePermission(context)) {
            return emptyList()
        }
        
        try {
            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val usageStatsList = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
            
            val packageManager = context.packageManager
            val result = mutableListOf<Map<String, Any>>()
            
            for (usageStats in usageStatsList) {
                if (usageStats.totalTimeInForeground > 0) {
                    try {
                        val appInfo = packageManager.getApplicationInfo(usageStats.packageName, 0)
                        val appName = packageManager.getApplicationLabel(appInfo).toString()
                        
                        val usageMap = mapOf(
                            "appName" to appName,
                            "packageName" to usageStats.packageName,
                            "usageTimeMinutes" to (usageStats.totalTimeInForeground / (1000 * 60)).toInt(),
                            "lastUsed" to usageStats.lastTimeUsed
                        )
                        
                        result.add(usageMap)
                    } catch (e: PackageManager.NameNotFoundException) {
                        // App not found, skip
                        android.util.Log.w("UsageStatsHelper", "App not found: ${usageStats.packageName}")
                    }
                }
            }
            
            return result
        } catch (e: Exception) {
            android.util.Log.e("UsageStatsHelper", "Error getting usage stats: ${e.message}")
            return emptyList()
        }
    }
    
    /**
     * Get current foreground app package name using UsageEvents (more accurate)
     */
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getCurrentForegroundApp(context: Context): String? {
        if (!hasUsagePermission(context)) {
            android.util.Log.w("UsageStatsHelper", "No usage permission")
            return null
        }
        
        try {
            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val currentTime = System.currentTimeMillis()
            
            // Use UsageEvents to get the most recent MOVE_TO_FOREGROUND event
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val usageEvents = usageStatsManager.queryEvents(currentTime - 60000, currentTime)
                var lastForegroundApp: String? = null
                var lastForegroundTime = 0L
                
                while (usageEvents.hasNextEvent()) {
                    val event = android.app.usage.UsageEvents.Event()
                    usageEvents.getNextEvent(event)
                    
                    // Track MOVE_TO_FOREGROUND events
                    if (event.eventType == android.app.usage.UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        if (event.timeStamp > lastForegroundTime) {
                            lastForegroundTime = event.timeStamp
                            lastForegroundApp = event.packageName
                        }
                    }
                }
                
                if (lastForegroundApp != null) {
                    android.util.Log.d("UsageStatsHelper", "Foreground app (events): $lastForegroundApp")
                    return lastForegroundApp
                }
            }
            
            // Fallback: Query usage stats for the last minute
            val usageStatsList = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                currentTime - 60000,
                currentTime
            )
            
            if (usageStatsList.isEmpty()) {
                android.util.Log.w("UsageStatsHelper", "No usage stats found")
                return null
            }
            
            // Get most recently used app
            val sortedStats = usageStatsList.sortedByDescending { it.lastTimeUsed }
            val foregroundApp = sortedStats.firstOrNull()?.packageName
            android.util.Log.d("UsageStatsHelper", "Foreground app (stats): $foregroundApp")
            return foregroundApp
        } catch (e: Exception) {
            android.util.Log.e("UsageStatsHelper", "Error getting foreground app: ${e.message}")
            return null
        }
    }
    
    /**
     * Get total usage time for a specific app today
     */
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getAppUsageToday(context: Context, packageName: String): Int {
        if (!hasUsagePermission(context)) {
            return 0
        }
        
        try {
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            val startOfDay = calendar.timeInMillis
            val now = System.currentTimeMillis()
            
            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val usageStatsList = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startOfDay,
                now
            )
            
            for (usageStats in usageStatsList) {
                if (usageStats.packageName == packageName) {
                    return (usageStats.totalTimeInForeground / (1000 * 60)).toInt()
                }
            }
            
            return 0
        } catch (e: Exception) {
            android.util.Log.e("UsageStatsHelper", "Error getting app usage: ${e.message}")
            return 0
        }
    }
}

