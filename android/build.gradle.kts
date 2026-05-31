allprojects {
    repositories {
        google()
        mavenCentral()
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

// Some plugins (e.g. file_picker 8.x) hardcode an old compileSdk that is too low
// for transitive dependencies like flutter_plugin_android_lifecycle, which require
// compileSdk 36+. Force every Android library subproject up to 36 so the AAR
// metadata check passes.
fun Project.forceLibraryCompileSdk() {
    extensions.findByType<com.android.build.api.dsl.LibraryExtension>()?.apply {
        compileSdk = 36
    }
}

subprojects {
    if (state.executed) {
        forceLibraryCompileSdk()
    } else {
        afterEvaluate {
            forceLibraryCompileSdk()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
