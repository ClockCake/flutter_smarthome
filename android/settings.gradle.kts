import java.util.Properties // <--- 确保这行存在并且在文件顶部

pluginManagement {
  repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
    // 本地 Flutter SDK 下的 gradle 脚本仓库
    val flutterSdk: String = Properties() // 这一行或者下一行是出错的第9行
      .apply { file("local.properties").inputStream().use(::load) }
      .getProperty("flutter.sdk")
      ?: throw GradleException("Flutter SDK not found. Define location in local.properties") // 建议增加一个空检查
    maven { url = uri("$flutterSdk/packages/flutter_tools/gradle") }
  }
  plugins {
    // 声明 loader
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP、Kotlin 插件版本声明（apply false）
    id("com.android.application") version "8.0.2" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
  }
}

include(":app")