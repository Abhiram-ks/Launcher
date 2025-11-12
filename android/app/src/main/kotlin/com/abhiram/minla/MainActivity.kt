package com.abhiram.minla
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "launcher_service"
        private const val APP_MANAGEMENT_CHANNEL = "app_management_service"
        private const val APP_EVENTS_CHANNEL = "app_events_stream"
    }

    private var packageChangeReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleLauncherIntent()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLauncherIntent()
    }

    private fun handleLauncherIntent() {
        val intent = intent ?: return
        val action = intent.action
        val categories = intent.categories

        if (Intent.ACTION_MAIN == action &&
            (categories?.contains(Intent.CATEGORY_HOME) == true ||
                    categories?.contains(Intent.CATEGORY_LAUNCHER) == true)
        ) {
            moveTaskToFront()
        }
    }

    private fun moveTaskToFront() {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupEventChannel(flutterEngine)
        setupLauncherChannel(flutterEngine)
        setupAppManagementChannel(flutterEngine)
    }

    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, APP_EVENTS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerPackageChangeReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterPackageChangeReceiver()
                    eventSink = null
                }
            })
    }

    private fun setupLauncherChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setAsDefaultLauncher" -> {
                        setAsDefaultLauncher()
                        result.success(null)
                    }
                    "checkDefaultLauncher" -> {
                        result.success(isDefaultLauncher())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupAppManagementChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_MANAGEMENT_CHANNEL)
            .setMethodCallHandler { call, result ->
                val packageName = call.argument<String>("packageName")
                if (packageName == null) {
                    result.error("INVALID_ARGUMENT", "Package name is required", null)
                    return@setMethodCallHandler
                }

                when (call.method) {
                    "openAppInfo" -> {
                        openAppInfo(packageName)
                        result.success(true)
                    }
                    "uninstallApp" -> {
                        result.success(uninstallApp(packageName))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setAsDefaultLauncher() {
        startActivity(Intent(Settings.ACTION_HOME_SETTINGS))
    }

    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    private fun openAppInfo(packageName: String) {
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = android.net.Uri.parse("package:$packageName")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(this)
        }
    }

    private fun uninstallApp(packageName: String): Boolean {
        return try {
            Intent(Intent.ACTION_DELETE).apply {
                data = android.net.Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(this)
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open uninstall dialog", e)
            false
        }
    }

    private fun registerPackageChangeReceiver() {
        if (packageChangeReceiver != null) return

        packageChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val packageName = intent?.data?.schemeSpecificPart ?: return
                val action = intent.action ?: return

                when (action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        val event = if (intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)) {
                            "app_updated"
                        } else {
                            "app_installed"
                        }
                        sendEvent(event, packageName)
                    }
                    Intent.ACTION_PACKAGE_REMOVED -> {
                        if (!intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)) {
                            sendEvent("app_uninstalled", packageName)
                        }
                    }
                    Intent.ACTION_PACKAGE_CHANGED -> {
                        sendEvent("app_changed", packageName)
                    }
                }
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

    private fun sendEvent(event: String, packageName: String) {
        eventSink?.success(mapOf("event" to event, "packageName" to packageName))
    }

    private fun unregisterPackageChangeReceiver() {
        packageChangeReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                Log.w(TAG, "Receiver was not registered", e)
            }
        }
        packageChangeReceiver = null
    }

    override fun onDestroy() {
        unregisterPackageChangeReceiver()
        super.onDestroy()
    }
}