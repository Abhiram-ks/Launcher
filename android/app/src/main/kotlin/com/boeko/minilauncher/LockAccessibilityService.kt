package com.boeko.minilauncher

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class LockAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // No-op: we only use this service to perform global actions
    }

    override fun onInterrupt() {
        // No-op
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }

    companion object {
        @Volatile
        private var instance: LockAccessibilityService? = null

        fun tryLockScreen(): Boolean {
            val svc = instance ?: return false
            return svc.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
        }
    }
}


