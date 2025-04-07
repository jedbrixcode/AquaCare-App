// Root-level build.gradle.kts

buildscript {
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.3") // Use version compatible with JDK 17+
        classpath("com.google.gms:google-services:4.3.15")
        
    }

    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.android.application") version "8.7.0" apply false
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
