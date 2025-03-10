plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
//    testOptions {
//        unitTests.all {
//            enabled = false  // Отключает unit tests для Android-плагинов <button class="citation-flag" data-index="3">, <button class="citation-flag" data-index="4">
//        }
//}
    namespace = "com.example.bookreader"
    compileSdk = 35 // Используйте актуальную версию SDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Java 17 для совместимости с AGP 8.x
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.bookreader"
        minSdk = 23 // Минимальная версия Android
        targetSdk = 35 // Целевая версия Android
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))

    // Firebase dependencies
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}