import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
}

// Rust core outputs (tasks at the end of this file).
val repoRoot: File = rootProject.projectDir.parentFile.parentFile
val rustJniLibs = layout.buildDirectory.dir("rust/jniLibs")
val uniffiBindings = layout.buildDirectory.dir("generated/uniffi")
val rustProfile = "release"

android {
    namespace = "app.meldeplanner.android"
    compileSdk = 37
    ndkVersion = "29.0.14206865"

    defaultConfig {
        applicationId = "app.meldeplanner.android"
        minSdk = 36
        targetSdk = 37
        versionCode = 1
        versionName = "0.1.0"
        // Only the ABIs the Rust core is built for.
        ndk { abiFilters += listOf("arm64-v8a", "x86_64") }
        manifestPlaceholders["teamsRedirectScheme"] = "meldeplanner"
    }

    buildTypes {
        release {
            // Side-loaded builds: signed with the debug key so the APK installs directly.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    buildFeatures { compose = true }

    sourceSets {
        getByName("main") {
            jniLibs.srcDir(rustJniLibs.get().asFile)
            kotlin.srcDir(uniffiBindings.get().asFile)
        }
    }

    packaging { jniLibs { useLegacyPackaging = false } }
}

dependencies {
    implementation(libs.androidx.core)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.compose.material3.adaptive.navigation.suite)
    implementation(libs.compose.material.icons)
    implementation(libs.glance.appwidget)
    implementation(libs.glance.material3)
    implementation(libs.work.runtime)
    implementation(libs.androidx.browser)
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.kotlinx.coroutines.android)
    // UniFFI's Kotlin bindings call the Rust library through JNA.
    implementation("${libs.jna.get()}@aar")
    // Document scanner (edge detection, crop, PDF), the counterpart of VisionKit on iOS.
    implementation(libs.mlkit.document.scanner)
    // Translucent, blurred app bars and navigation (backdrop blur), the counterpart of iOS
    // materials; Compose has no built-in backdrop blur.
    implementation(libs.haze)
    implementation(libs.haze.blur)
    implementation(libs.haze.blur.materials)
    debugImplementation(libs.compose.ui.tooling)
    testImplementation(libs.junit)
}

// --- Rust core (crates/melde-ffi) -------------------------------------------------
// Builds libmelde_ffi.so with cargo-ndk and generates the Kotlin bindings with the
// pinned uniffi-bindgen, the same way scripts/build-rust-ios.sh does for Swift.


fun sdkDir(): File {
    val props = Properties()
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use(props::load)
    val path = props.getProperty("sdk.dir") ?: System.getenv("ANDROID_HOME") ?: System.getenv("ANDROID_SDK_ROOT")
    return File(requireNotNull(path) { "Set sdk.dir in local.properties or ANDROID_HOME" })
}

val cargoBuildRust = tasks.register<Exec>("cargoBuildRust") {
    group = "rust"
    description = "Builds the Rust core for Android with cargo-ndk."
    workingDir = repoRoot
    // NDK r29 ships sysroots up to API 35; the library uses no newer native API.
    environment("ANDROID_NDK_HOME", sdkDir().resolve("ndk/${android.ndkVersion}").path)
    commandLine(
        "cargo", "ndk", "-t", "arm64-v8a", "-t", "x86_64", "--platform", "35",
        "-o", rustJniLibs.get().asFile.path,
        "build", "-p", "melde-ffi", "--locked", "--$rustProfile",
    )
    inputs.dir(repoRoot.resolve("crates"))
    inputs.file(repoRoot.resolve("Cargo.lock"))
    outputs.dir(rustJniLibs)
}

// Release libraries are stripped, so bindgen reads the UniFFI metadata from a host build.
val cargoBuildHost = tasks.register<Exec>("cargoBuildHost") {
    group = "rust"
    workingDir = repoRoot
    commandLine("cargo", "build", "-q", "-p", "melde-ffi", "--locked")
    inputs.dir(repoRoot.resolve("crates"))
    outputs.dir(repoRoot.resolve("target/debug"))
}

val generateUniffiBindings = tasks.register<Exec>("generateUniffiBindings") {
    group = "rust"
    description = "Generates the Kotlin bindings for the Rust core."
    dependsOn(cargoBuildRust, cargoBuildHost)
    workingDir = repoRoot
    val os = System.getProperty("os.name").lowercase()
    val hostLib = when {
        "windows" in os -> "melde_ffi.dll"
        "mac" in os -> "libmelde_ffi.dylib"
        else -> "libmelde_ffi.so"
    }
    val library = repoRoot.resolve("target/debug/$hostLib")
    commandLine(
        "cargo", "run", "-q", "-p", "uniffi-bindgen", "--locked", "--",
        "generate", "--library", library.path, "--language", "kotlin", "--no-format",
        "--out-dir", uniffiBindings.get().asFile.path,
    )
    inputs.dir(repoRoot.resolve("crates"))
    outputs.dir(uniffiBindings)
}

tasks.named("preBuild") { dependsOn(generateUniffiBindings) }

// --- Strings ----------------------------------------------------------------------
// One catalog for both apps: the iOS String Catalog (German keys, de/tr/en) plus the
// few Android-only strings, merged into assets/strings.json for L(…).

val generateStrings = tasks.register("generateStrings") {
    group = "meldo"
    val catalog = repoRoot.resolve("apps/ios/MeldePlanner/Resources/Localizable.xcstrings")
    // Android-only strings, one file per feature: strings/<feature>.json = { key: { de, tr, en } }.
    val androidOnly = rootProject.fileTree("strings") { include("*.json") }
    val output = layout.buildDirectory.file("generated/strings/assets/strings.json")
    inputs.file(catalog)
    inputs.files(androidOnly)
    outputs.file(output)
    doLast {
        @Suppress("UNCHECKED_CAST")
        val strings = (groovy.json.JsonSlurper().parse(catalog) as Map<String, Any>)["strings"] as Map<String, Map<String, Any>>
        val merged = sortedMapOf<String, List<String>>()
        for ((key, entry) in strings) {
            @Suppress("UNCHECKED_CAST")
            val locs = entry["localizations"] as? Map<String, Map<String, Map<String, String>>> ?: emptyMap()
            merged[key] = listOf("de", "tr", "en").map { locs[it]?.get("stringUnit")?.get("value") ?: key }
        }
        for (file in androidOnly.files.sortedBy { it.name }) {
            @Suppress("UNCHECKED_CAST")
            val extra = groovy.json.JsonSlurper().parse(file) as Map<String, Map<String, String>>
            for ((key, values) in extra) merged[key] = listOf("de", "tr", "en").map { values[it] ?: key }
        }
        val file = output.get().asFile
        file.parentFile.mkdirs()
        file.writeText(groovy.json.JsonOutput.toJson(merged), Charsets.UTF_8)
    }
}

android.sourceSets.getByName("main").assets.srcDir(layout.buildDirectory.dir("generated/strings/assets").get().asFile)
tasks.named("preBuild") { dependsOn(generateStrings) }
