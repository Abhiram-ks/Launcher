package com.abhiram.minla

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "launcher_service"
    private val APP_MANAGEMENT_CHANNEL = "app_management_service"
    private val APP_EVENTS_CHANNEL = "app_events_stream"

    private var packageChangeReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(
            android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    android.view.WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup EventChannel for app install/uninstall events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, APP_EVENTS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerPackageChangeReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterPackageChangeReceiver()
                    eventSink = null
                }
            }
        )

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_MANAGEMENT_CHANNEL).setMethodCallHandler { call, result ->
            val packageName = call.argument<String>("packageName")
            when (call.method) {
                "uninstallApp" -> {
                    if (packageName != null && packageName.isNotEmpty()) {
                        android.util.Log.d("MainActivity", "Uninstall requested for package: $packageName")
                        try {
                            uninstallApp(packageName)
                            android.util.Log.d("MainActivity", "Uninstall intent started successfully")
                            result.success(true)
                        } catch (e: Exception) {
                            android.util.Log.e("MainActivity", "Uninstall failed: ${e.message}", e)
                            result.error("UNINSTALL_FAILED", e.message ?: "Unknown error", null)
                        }
                    } else {
                        android.util.Log.e("MainActivity", "Invalid package name: $packageName")
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "openAppInfo" -> {
                    if (packageName != null) {
                        try {
                            openAppInfo(packageName)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("OPEN_INFO_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                else -> result.notImplemented()
            }
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


    private fun uninstallApp(packageName: String) {
        android.util.Log.d("MainActivity", "uninstallApp called for: $packageName")
        
        try {
            // Check if package exists
            try {
                packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                android.util.Log.d("MainActivity", "Package exists: $packageName")
            } catch (e: PackageManager.NameNotFoundException) {
                android.util.Log.e("MainActivity", "Package not found: $packageName")
                throw Exception("Package not found: $packageName")
            }

            val intent = Intent(Intent.ACTION_DELETE).apply {
                data = android.net.Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                // Ensure it appears above launcher
                addCategory(Intent.CATEGORY_DEFAULT)
            }

            android.util.Log.d("MainActivity", "Created uninstall intent for: $packageName")

            // Verify intent can be handled
            val resolveInfo = intent.resolveActivity(packageManager)
            if (resolveInfo != null) {
                android.util.Log.d("MainActivity", "Intent can be resolved, starting activity")
                try {
                    startActivity(intent)
                    android.util.Log.d("MainActivity", "Uninstall activity started successfully")
                } catch (e: android.content.ActivityNotFoundException) {
                    android.util.Log.e("MainActivity", "Activity not found: ${e.message}")
                    throw Exception("Cannot open uninstall dialog. Activity not found.")
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Failed to start activity: ${e.message}", e)
                    throw Exception("Failed to start uninstall activity: ${e.message}")
                }
            } else {
                android.util.Log.e("MainActivity", "No activity found to handle uninstall intent")
                throw Exception("No activity found to handle uninstall intent. Please check if package manager is available.")
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to uninstall app: ${e.message}", e)
            throw e
        }
    }

    private fun openAppInfo(packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = android.net.Uri.parse("package:$packageName")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun registerPackageChangeReceiver() {
        if (packageChangeReceiver != null) return

        packageChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val packageName = intent?.data?.schemeSpecificPart ?: return
                val eventMap = when (intent.action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        val event = if (intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)) {
                            "app_updated"
                        } else {
                            "app_installed"
                        }
                        mapOf("event" to event, "packageName" to packageName)
                    }
                    Intent.ACTION_PACKAGE_REMOVED -> {
                        if (!intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)) {
                            mapOf("event" to "app_uninstalled", "packageName" to packageName)
                        } else null
                    }
                    Intent.ACTION_PACKAGE_CHANGED -> {
                        mapOf("event" to "app_changed", "packageName" to packageName)
                    }
                    else -> null
                }
                eventMap?.let { eventSink?.success(it) }
            }
        }

        IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_CHANGED)
            addDataScheme("package")
        }.let { filter ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(packageChangeReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(packageChangeReceiver, filter)
            }
        }
    }

    private fun unregisterPackageChangeReceiver() {
        packageChangeReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                // Receiver was not registered - ignore
            }
            packageChangeReceiver = null
        }
    }

    override fun onDestroy() {
        unregisterPackageChangeReceiver()
        super.onDestroy()
    }
}