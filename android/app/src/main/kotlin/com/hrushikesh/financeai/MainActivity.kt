package com.hrushikesh.financeai

import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SMS_CHANNEL = "com.hrushikesh.financeai/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInboxSms" -> {
                    val count = call.argument<Int>("count") ?: 50
                    val afterTimestamp = call.argument<Long>("afterTimestamp") ?: 0L
                    try {
                        val smsList = readSmsInbox(count, afterTimestamp)
                        result.success(smsList)
                    } catch (e: Exception) {
                        result.error("SMS_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readSmsInbox(count: Int, afterTimestamp: Long): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("address", "body", "date")
        val selection = if (afterTimestamp > 0) "date > ?" else null
        val selectionArgs = if (afterTimestamp > 0) arrayOf(afterTimestamp.toString()) else null
        val sortOrder = "date DESC LIMIT $count"

        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
            cursor?.let {
                val addressIdx = it.getColumnIndex("address")
                val bodyIdx = it.getColumnIndex("body")
                val dateIdx = it.getColumnIndex("date")
                while (it.moveToNext()) {
                    val sms = mapOf<String, Any>(
                        "sender" to (if (addressIdx >= 0) it.getString(addressIdx) ?: "" else ""),
                        "body" to (if (bodyIdx >= 0) it.getString(bodyIdx) ?: "" else ""),
                        "timestamp" to (if (dateIdx >= 0) it.getLong(dateIdx) else 0L)
                    )
                    smsList.add(sms)
                }
            }
        } finally {
            cursor?.close()
        }
        return smsList
    }
}
