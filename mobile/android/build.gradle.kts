plugins {
    // Add the Google services Gradle plugin (apply in app module)
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Only redirect build directory if the subproject is located within the project root.
    // This prevents "different roots" errors when plugins are on a different drive (e.g. pub cache on C: vs project on D:).
    val workspeaceDir = rootProject.projectDir.parentFile
    if (project.projectDir.absolutePath.startsWith(workspeaceDir.absolutePath)) {
        project.layout.buildDirectory.set(newBuildDir.dir(project.name))
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
