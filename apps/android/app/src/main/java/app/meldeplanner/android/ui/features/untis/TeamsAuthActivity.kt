package app.meldeplanner.android.ui.features.untis

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.net.toUri
import app.meldeplanner.android.MainActivity
import app.meldeplanner.android.data.TeamsFailure
import kotlinx.coroutines.CompletableDeferred

/**
 * The Microsoft sign-in in a Custom Tab, the counterpart of iOS'
 * `webAuthenticationSession`: [authenticate] opens Microsoft's page and waits for the
 * redirect to `meldeplanner://auth`, which [TeamsAuthActivity] receives.
 */
object TeamsAuthSession {
    @Volatile private var pending: CompletableDeferred<String>? = null

    /** Opens [url] and suspends until Microsoft redirects back; throws [TeamsFailure.Cancelled] when closed. */
    suspend fun authenticate(context: Context, url: String): String {
        pending?.cancel()
        val deferred = CompletableDeferred<String>()
        pending = deferred
        CustomTabsIntent.Builder().setShowTitle(true).build().launchUrl(context, url.toUri())
        try {
            return deferred.await()
        } finally {
            if (pending === deferred) pending = null
        }
    }

    /** The student came back to Meldo without finishing the sign-in. */
    fun cancel() {
        pending?.completeExceptionally(TeamsFailure.Cancelled)
    }

    val isWaiting: Boolean get() = pending?.isActive == true

    internal fun complete(callback: String): Boolean = pending?.complete(callback) ?: false
}

/**
 * Receives `meldeplanner://auth?code=…` from the browser, hands it to the waiting
 * sign-in and returns to Meldo (closing the Custom Tab above it).
 */
class TeamsAuthActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.data?.toString()?.let(TeamsAuthSession::complete)
        startActivity(
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP),
        )
        finish()
    }
}
