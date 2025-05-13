
allprojects {
  repositories {
    // Flutter Engine AAR
    maven { url = uri("$rootDir/../flutter/packages/flutter_tools/gradle") }
    google()
    mavenCentral()
  }
}

// ─────────────────────────────────────────────────────
// 下面是你原来的目录重定向逻辑，无需改动：
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
  val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
  project.layout.buildDirectory.value(newSubprojectBuildDir)
  evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
  delete(rootProject.layout.buildDirectory)
}
dependencies {
    implementation("androidx.room:room-compiler:2.7.1")
}
