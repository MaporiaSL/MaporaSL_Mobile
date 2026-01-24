allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep build outputs on the same drive as plugin sources to avoid path mismatches
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

