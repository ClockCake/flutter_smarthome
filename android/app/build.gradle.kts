plugins {
  // Android 应用插件
  id("com.android.application")
  // Kotlin Android 插件
  id("org.jetbrains.kotlin.android")
  // Flutter Gradle 插件
  id("dev.flutter.flutter‑gradle‑plugin")
}
android {
    namespace = "com.jiyoujiaju.jijiahui"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.jiyoujiaju.jijiahui"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    implementation("androidx.recyclerview:recyclerview:1.4.0")
    implementation("androidx.cardview:cardview:1.0.0")
    implementation(kotlin("stdlib-jdk7"))
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.tencent.mm.opensdk:wechat-sdk-android:6.8.24")
    implementation("com.google.code.gson:gson:2.9.0") 
    implementation("com.google.android.exoplayer:exoplayer-common:2.18.7")
    implementation("androidx.coordinatorlayout:coordinatorlayout:1.2.0")
}

flutter {
    source = "../.."
}


