// android/build.gradle.kts

buildscript {
    repositories {
        google()        // ✅ Required for Firebase Gradle plugin
        mavenCentral()  // ✅ Optional but recommended
    }

    dependencies {
        classpath("com.google.gms:google-services:4.4.1") // ✅ Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
