package app.meldeplanner.android.model

import android.content.Context
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import app.meldeplanner.android.MeldoApp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit
import kotlin.coroutines.coroutineContext

/**
 * Keeps WebUntis (and Teams) data current in the background, the counterpart of
 * iOS' Background App Refresh task in MeldePlannerApp.swift. Android decides the
 * exact time; WorkManager runs it about every 30 minutes when there is a network.
 */
object BackgroundRefresh {
    const val WORK_NAME = "app.meldeplanner.android.refresh"

    /** How often the open app checks whether an update is due (the iOS 5-minute loop). */
    const val FOREGROUND_CHECK_MINUTES = 5L

    /** Plans the periodic background update; keeps an existing schedule. */
    fun schedule(context: Context) {
        val request = PeriodicWorkRequestBuilder<Worker>(untisRefreshInterval.toMinutes(), TimeUnit.MINUTES)
            .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
            .build()
        WorkManager.getInstance(context.applicationContext)
            .enqueueUniquePeriodicWork(WORK_NAME, ExistingPeriodicWorkPolicy.KEEP, request)
    }

    /** Runs when Android wakes Meldo: update WebUntis and Teams if they're due. */
    suspend fun run(model: AppModel) = withContext(Dispatchers.Main) {
        model.reloadFromDisk()
        model.refreshUntisIfStale()
        model.refreshTeamsIfStale()
    }

    /**
     * While the app is open: check every few minutes, update when 30 minutes old.
     * Call from a lifecycle-bound coroutine (e.g. `repeatOnLifecycle(STARTED)`), so it
     * stops in the background.
     */
    suspend fun foregroundLoop(model: AppModel) {
        while (coroutineContext.isActive) {
            delay(TimeUnit.MINUTES.toMillis(FOREGROUND_CHECK_MINUTES))
            withContext(Dispatchers.Main) { model.refreshUntisIfStale() }
        }
    }

    class Worker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
        override suspend fun doWork(): Result {
            // The app's model once it exists; a pure background start creates it here.
            val model = (applicationContext as MeldoApp).model
            BackgroundRefresh.run(model)
            return Result.success()
        }
    }
}
