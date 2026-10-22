package app.meldeplanner.android.core

import android.app.LocaleManager
import android.content.Context
import android.os.LocaleList
import app.meldeplanner.android.data.AppLanguage
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.util.Locale

/**
 * In-app language switching (German default, Turkish, English), like the iOS
 * `Localization`. Keys are the German source strings of the shared String Catalog
 * (apps/ios/MeldePlanner/Resources/Localizable.xcstrings), merged at build time
 * into assets/strings.json, so both apps say exactly the same thing.
 */
object Localization {
    @Volatile private var table: Map<String, List<String>> = emptyMap()
    @Volatile var language: AppLanguage = AppLanguage.german
        private set

    val locale: Locale get() = Locale.forLanguageTag(language.code)

    fun load(context: Context) {
        if (table.isNotEmpty()) return
        val text = context.assets.open("strings.json").bufferedReader().use { it.readText() }
        table = Json.parseToJsonElement(text).jsonObject.mapValues { (_, v) ->
            v.jsonArray.map { it.jsonPrimitive.content }
        }
    }

    fun apply(language: AppLanguage) {
        this.language = language
    }

    /**
     * Makes the app language Android's per-app language too, so system components
     * (date and time pickers, number formats, TalkBack labels) speak it. Android
     * recreates the activity when it changes.
     */
    fun applyToSystem(context: Context, language: AppLanguage) {
        val manager = context.getSystemService(LocaleManager::class.java) ?: return
        val wanted = LocaleList.forLanguageTags(language.code)
        if (manager.applicationLocales != wanted) manager.applicationLocales = wanted
    }

    /** 24-hour clock for German and Turkish; English follows the device setting. */
    fun is24Hour(context: Context): Boolean =
        language != AppLanguage.english || android.text.format.DateFormat.is24HourFormat(context)

    fun lookup(key: String): String {
        val index = when (language) {
            AppLanguage.german -> 0
            AppLanguage.turkish -> 1
            AppLanguage.english -> 2
        }
        return table[key]?.getOrNull(index) ?: key
    }
}

private val swiftSpecifier = Regex("""%(\d+\$)?(lld|ld|@|d|f|\.\df)""")

/**
 * Localized string in the app language. [key] is the catalog key exactly as Swift
 * produces it ("%lld Meldungen diese Woche", "%@ statt %@"); [args] fill it in.
 */
fun L(key: String, vararg args: Any?): String {
    val value = Localization.lookup(key)
    if (args.isEmpty()) return value
    val format = swiftSpecifier.replace(value) { m ->
        val position = m.groupValues[1]
        when (val spec = m.groupValues[2]) {
            "lld", "ld", "d" -> "%${position}d"
            "@" -> "%${position}s"
            else -> "%$position$spec"
        }
    }
    return String.format(Localization.locale, format, *args)
}
