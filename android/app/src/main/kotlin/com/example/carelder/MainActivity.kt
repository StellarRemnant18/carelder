
package com.example.carelder

import android.content.Intent
import android.os.Bundle
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.HeartRateRecord
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "caringmate/health_connect"
    private val requestCode = 1001

    private var pendingPermissionResult: MethodChannel.Result? = null

    private val requestedPermissions = setOf(
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getReadPermission(HeartRateRecord::class)
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "checkAvailability" -> {
                    val status = HealthConnectClient.getSdkStatus(this)

                    val response = when (status) {
                        HealthConnectClient.SDK_AVAILABLE -> "available"
                        HealthConnectClient.SDK_UNAVAILABLE -> "unavailable"
                        HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED ->
                            "update_required"
                        else -> "unknown"
                    }

                    result.success(response)
                }

                "requestPermissions" -> {
                    val status = HealthConnectClient.getSdkStatus(this)

                    if (status != HealthConnectClient.SDK_AVAILABLE) {
                        result.error(
                            "HEALTH_CONNECT_UNAVAILABLE",
                            "Health Connect is unavailable or requires an update.",
                            null
                        )
                    } else if (pendingPermissionResult != null) {
                        result.error(
                            "REQUEST_IN_PROGRESS",
                            "A permission request is already running.",
                            null
                        )
                    } else {
                        try {
                            val contract =
                                PermissionController
                                    .createRequestPermissionResultContract()

                            val intent = contract.createIntent(
                                this,
                                requestedPermissions
                            )

                            pendingPermissionResult = result

                            startActivityForResult(intent, requestCode)

                        } catch (e: Exception) {
                            pendingPermissionResult = null
                            result.error(
                                "PERMISSION_REQUEST_FAILED",
                                e.message,
                                null
                            )
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Android API")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == this.requestCode) {
            val contract =
                PermissionController.createRequestPermissionResultContract()

            val grantedPermissions =
                contract.parseResult(resultCode, data)

            pendingPermissionResult?.success(
                mapOf(
                    "steps" to grantedPermissions.contains(
                        HealthPermission.getReadPermission(StepsRecord::class)
                    ),
                    "heartRate" to grantedPermissions.contains(
                        HealthPermission.getReadPermission(HeartRateRecord::class)
                    )
                )
            )

            pendingPermissionResult = null
        }
    }
}
