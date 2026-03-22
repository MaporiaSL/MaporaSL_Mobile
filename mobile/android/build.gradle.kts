allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://test.payhere.lk/lib") }
        maven { url = uri("https://test.payhere.lk/lib") }
        // Note: the documentation for payhere android sdk mentions this URL:
        maven { url = uri("https://jitpack.io") }
        maven {
            url = uri("https://s3.amazonaws.com/nexus-payhere/payhere-android-sdk")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
