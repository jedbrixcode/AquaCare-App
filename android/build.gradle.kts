buildscript {
    ext.kotlin_version = '1.6.0'
    repositories {
      google()  
      jcenter()
      mavenCentral()  
    }

    dependencies {
      classpath ('com.android.tools.build:gradle:4.1.0')
      classpath ("org.jetbrains.kotlin:kotlin-grade-plugin:$kotlinVersion")
      classpath ('com.google.gms:google-services:4.3.13')
    }
}

allprojects {
    repositories {
        google()
        jcenter()
        mavenCentral()
    }
}

plugins {
  id("com.google.gms.google-services") version "4.3.15" apply false
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
