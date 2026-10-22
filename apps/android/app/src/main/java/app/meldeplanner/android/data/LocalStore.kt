package app.meldeplanner.android.data

import android.content.Context
import java.io.File
import java.io.IOException

/**
 * Device-local persistence as one JSON document (data.json), written atomically.
 * Same format and rules as the iOS LocalStore: every write goes through [update],
 * which reads the latest file under a lock and applies the change, so a Meldung
 * logged from a widget, the Quick Settings tile or a notification is never
 * overwritten by the app. All of them run in this process, so one lock is enough.
 */
class LocalStore(val file: File) {
    sealed class LoadException(message: String) : Exception(message) {
        class Unreadable(cause: Throwable, val backup: File?) : LoadException("unreadable: ${cause.message}")
        class NewerSchema(val version: Int) : LoadException("schema $version is newer than this app")
    }

    fun load(): AppData = synchronized(LOCK) { read().getOrThrow() }

    /** Reads the latest file, applies [change] and writes it back under one lock. */
    fun update(change: (AppData) -> Unit): AppData = synchronized(LOCK) {
        val data = read().getOrElse { error ->
            when (error) {
                // A backup was kept by `read`; start fresh rather than blocking every save.
                is LoadException.Unreadable -> AppData()
                // Never overwrite data written by a newer app version.
                else -> throw error
            }
        }
        change(data)
        write(data)
        data
    }

    /** Overwrites the file. Only for tests and recovery; normal code uses [update]. */
    fun save(data: AppData) = synchronized(LOCK) { write(data) }

    private fun read(): Result<AppData> {
        if (!file.exists()) return Result.success(AppData())
        return try {
            val decoded = MeldoJson.decodeFromString(AppData.serializer(), file.readText())
            if (decoded.schemaVersion > AppData.CURRENT_SCHEMA_VERSION) {
                Result.failure(LoadException.NewerSchema(decoded.schemaVersion))
            } else {
                // Older files are migrated in memory; the next write stores the current version.
                decoded.schemaVersion = AppData.CURRENT_SCHEMA_VERSION
                Result.success(decoded)
            }
        } catch (e: Exception) {
            // Keep the unreadable file instead of overwriting the student's data.
            Result.failure(LoadException.Unreadable(e, backupCorruptFile()))
        }
    }

    private fun write(data: AppData) {
        file.parentFile?.mkdirs()
        val temp = File(file.parentFile, "${file.name}.tmp")
        temp.writeText(MeldoJson.encodeToString(AppData.serializer(), data))
        if (!temp.renameTo(file)) {
            file.delete()
            if (!temp.renameTo(file)) throw IOException("could not replace ${file.name}")
        }
    }

    private fun backupCorruptFile(): File? {
        val backup = File(file.parentFile, "data-unreadable-${System.currentTimeMillis() / 1000}.json")
        return runCatching { file.copyTo(backup) }.getOrNull()
    }

    companion object {
        private val LOCK = Any()

        /** The app's store in internal storage (private to Meldo, excluded from other apps). */
        fun standard(context: Context) = LocalStore(File(context.filesDir, "MeldePlanner/data.json"))
    }
}
