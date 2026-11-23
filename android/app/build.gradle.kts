import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val candidateKeyFiles = listOf(
    rootProject.file("key.properties"),
    project.file("key.properties"),
    project.file("../key.properties"),
    File(projectDir.parentFile, "key.properties")
)
val keyFile = candidateKeyFiles.firstOrNull { it.exists() }
if (keyFile != null) {
    keystoreProperties.load(FileInputStream(keyFile))
}

android {
    namespace = "com.wincoconnect.winco_connect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wincoconnect.winco_connect"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyStorePath = keystoreProperties.getProperty("storeFile")
                ?: System.getenv("WINCO_KEYSTORE_PATH")
            val keyStorePassword = keystoreProperties.getProperty("storePassword")
                ?: System.getenv("WINCO_KEYSTORE_PASSWORD")
            val keyAliasVal = keystoreProperties.getProperty("keyAlias")
                ?: System.getenv("WINCO_KEY_ALIAS")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
                ?: System.getenv("WINCO_KEY_PASSWORD")

            if (!keyStorePath.isNullOrBlank() &&
                !keyStorePassword.isNullOrBlank() &&
                !keyAliasVal.isNullOrBlank() &&
                !keyPasswordVal.isNullOrBlank()
            ) {
                val f = file(keyStorePath)
                if (f.exists()) {
                    storeFile = f
                    storePassword = keyStorePassword
                    keyAlias = keyAliasVal
                    keyPassword = keyPasswordVal
                } else {
                    throw GradleException("Release keystore file not found at: \$keyStorePath. Do not fall back to debug signing!")
                }
            } else {
                throw GradleException("Release signing configuration missing! Either configure android/key.properties (excluded from Git) or set environment variables (WINCO_KEYSTORE_PATH, WINCO_KEYSTORE_PASSWORD, WINCO_KEY_ALIAS, WINCO_KEY_PASSWORD). Debug signing for release builds is strictly prohibited.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
