#!/bin/bash
set -euo pipefail

# =============================================================================
# preprocess.sh — Renames org.lwjgl → org.lwjgl3 and reconfigures Maven publish
#
# Usage: bash preprocess.sh
#
# This script performs:
#   1. Package rename:  org.lwjgl  → org.lwjgl3  (Java/Kotlin/XML)
#   2. JNI symbol rename: org_lwjgl → org_lwjgl3  (C/CPP/H)
#   3. Directory rename:  org/lwjgl/ → org/lwjgl3/ (source trees)
#   4. C file rename:     org_lwjgl_* → org_lwjgl3_*
#   5. BindingConfig path: "org/lwjgl" → "org/lwjgl3"
#   6. gradle.properties: version from git describe --tags
#   7. build.gradle.kts: groupId→com.cleanroommc, repo URL hardcoded,
#      credentials from env, signing removed
#   8. ant clean-generated (remove old generated sources)
# =============================================================================

cd "$(git rev-parse --show-toplevel)"

# ---- Idempotency check ------------------------------------------------------
# Check if already preprocessed by looking for org.lwjgl3 in source directories
if find . -type d -path '*/org/lwjgl3' ! -path './.git/*' ! -path './bin/*' | grep -q . 2>/dev/null; then
    echo "[preprocess] Already preprocessed (org/lwjgl3 directory found). Skipping."
    exit 0
fi

echo "[preprocess] Starting package rename org.lwjgl → org.lwjgl3"

# ---- 1. Text replacement: org.lwjgl → org.lwjgl3 ---------------------------
# Use \b word boundary to avoid touching "lwjgl.org" domain references.
# \b before "org" ensures we match the start of "org.lwjgl".
# \b after "lwjgl" ensures we don't match "lwjgl.org" (the . is non-word, \b matches).
# This regex matches "org.lwjgl" at end-of-token boundary, NOT "lwjgl.org".

echo "[preprocess] Replacing org.lwjgl → org.lwjgl3 in source files..."

# Find all relevant text files, excluding .git, bin, and binary files
find . \
    -type f \
    \( \
        -name '*.java' -o \
        -name '*.kt' -o \
        -name '*.xml' -o \
        -name '*.args' -o \
        -name '*.json' -o \
        -name '*.properties' \
    \) \
    ! -path './.git/*' \
    ! -path './bin/*' \
    ! -path './.gradle/*' \
    -print0 | while IFS= read -r -d '' f; do
    # Replace org.lwjgl → org.lwjgl3 (word boundary, not lwjgl.org)
    sed -i 's/\borg\.lwjgl\b/org.lwjgl3/g' "$f"
done

# Also replace path-style "org/lwjgl" → "org/lwjgl3" in source and config files.
# This handles:
#   - BindingConfig.java line 73: "org/lwjgl" and "org/lwjgl/" (native lib path)
#   - Version.java line 75: "org/lwjgl/Version.class" (resource lookup)
#   - URLValidator.java: "src/generated/java/org/lwjgl" (path)
#   - config XMLs: includes="org/lwjgl/**", fileset dir=".../org/lwjgl"
#   - C headers: #include "org/lwjgl/..." (if any)
#   - Generator.kt: path references in comments and code
#
# We use a literal replacement of "org/lwjgl" → "org/lwjgl3" which is safe because
# "org/lwjgl" only appears as a path prefix, never as a domain name.

echo "[preprocess] Replacing path org/lwjgl → org/lwjgl3 in source/config files..."

find . \
    -type f \
    \( \
        -name '*.java' -o \
        -name '*.kt' -o \
        -name '*.xml' -o \
        -name '*.json' -o \
        -name '*.args' -o \
        -name '*.c' -o \
        -name '*.cpp' -o \
        -name '*.h' -o \
        -name '*.hpp' \
    \) \
    ! -path './.git/*' \
    ! -path './bin/*' \
    ! -path './.gradle/*' \
    -print0 | while IFS= read -r -d '' f; do
    sed -i 's|org/lwjgl|org/lwjgl3|g' "$f"
done

# ---- 2. C/JNI symbol replacement: org_lwjgl → org_lwjgl3 --------------------
# This covers:
#   Java_org_lwjgl_  → Java_org_lwjgl3_
#   org_lwjgl_malloc → org_lwjgl3_malloc (and calloc/realloc/free/aligned_*)
#   *org_lwjgl_*     → *org_lwjgl3_* (version.script glob)
#
# Kotlin template files (.kt) are also included because they contain
# embedded C macros (e.g. NVG_MALLOC, VMA_SYSTEM_ALIGNED_MALLOC) that
# reference org_lwjgl_* symbols. These templates are used by ant generate
# to produce the C source files, so they must be renamed too.
#
# We use a simple literal replacement: org_lwjgl → org_lwjgl3
# This is safe because "org_lwjgl" only appears as JNI/identifier prefixes.

echo "[preprocess] Replacing org_lwjgl → org_lwjgl3 in C/CPP/H/KT files..."

find . \
    -type f \
    \( \
        -name '*.c' -o \
        -name '*.cpp' -o \
        -name '*.cc' -o \
        -name '*.h' -o \
        -name '*.hpp' -o \
        -name '*.kt' -o \
        -name '*.script' -o \
        -name '*.def' \
    \) \
    ! -path './.git/*' \
    ! -path './bin/*' \
    -print0 | while IFS= read -r -d '' f; do
    sed -i 's/org_lwjgl/org_lwjgl3/g' "$f"
done

# XML build configs reference C source files by name in exclude/include patterns
# (e.g. org_lwjgl_system_SharedLibraryUtil.c, org_lwjgl_opengl_WGL.c). These
# files are renamed above, so the patterns must match. We cannot use the blanket
# org_lwjgl→org_lwjgl3 replacement here because step 1 already changed
# org.lwjgl→org.lwjgl3 in XML files; doing it again would corrupt org_lwjgl3
# into org_lwjgl33. Instead we match only underscore-style C identifiers:
# org_lwjgl_ followed by more identifier characters.

echo "[preprocess] Replacing org_lwjgl_ → org_lwjgl3_ in XML build configs..."

find config -type f -name '*.xml' -print0 | while IFS= read -r -d '' f; do
    sed -i 's/\borg_lwjgl_/org_lwjgl3_/g' "$f"
done

# Also handle version.script files (no extension or .script)
for f in config/linux/version.script config/freebsd/version.script; do
    if [ -f "$f" ]; then
        sed -i 's/org_lwjgl/org_lwjgl3/g' "$f"
    fi
done

# Also handle .args files (may contain -Dorg.lwjgl. properties)
# Already covered by text replacement above, but double-check config/cli/
for f in config/cli/*.args; do
    if [ -f "$f" ]; then
        sed -i 's/\borg\.lwjgl\b/org.lwjgl3/g' "$f"
    fi
done

# ---- 3. Directory rename: org/lwjgl/ → org/lwjgl3/ -------------------------
# Rename Java/Kotlin source directories from org/lwjgl/ to org/lwjgl3/

echo "[preprocess] Renaming directories org/lwjgl → org/lwjgl3..."

# Find all directories named "lwjgl" that are children of "org"
# Process deepest first to avoid moving a parent before its children
find . \
    -type d \
    -path '*/org/lwjgl' \
    ! -path './.git/*' \
    ! -path './bin/*' \
    ! -path './.gradle/*' \
    -print0 | sort -rz | while IFS= read -r -d '' d; do
    newdir="${d%lwjgl}lwjgl3"
    if [ -d "$newdir" ]; then
        # Merge contents if target exists
        cp -r "$d"/* "$newdir"/ 2>/dev/null || true
        rm -rf "$d"
    else
        git mv "$d" "$newdir" 2>/dev/null || mv "$d" "$newdir"
    fi
    echo "  $d → $newdir"
done

# ---- 4. C source file rename: org_lwjgl_* → org_lwjgl3_* -------------------

echo "[preprocess] Renaming C files org_lwjgl_* → org_lwjgl3_*..."

find . \
    -type f \
    -name 'org_lwjgl_*' \
    ! -path './.git/*' \
    ! -path './bin/*' \
    -print0 | while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    newname="org_lwjgl3_${base#org_lwjgl_}"
    git mv "$f" "$dir/$newname" 2>/dev/null || mv "$f" "$dir/$newname"
    echo "  $f → $dir/$newname"
done

# ---- 5. Verify no lwjgl.org domain was corrupted ----------------------------

echo "[preprocess] Verifying no lwjgl.org domain corruption..."
CORRUPTED=$(grep -r 'lwjgl3\.org' --include='*.java' --include='*.kt' --include='*.xml' --include='*.h' --include='*.c' . 2>/dev/null | grep -v '.git' | head -5 || true)
if [ -n "$CORRUPTED" ]; then
    echo "[preprocess] WARNING: Found lwjgl3.org references (possible domain corruption):"
    echo "$CORRUPTED"
    echo "[preprocess] Restoring lwjgl.org where corrupted..."
    find . \
        -type f \
        \( -name '*.java' -o -name '*.kt' -o -name '*.xml' -o -name '*.h' -o -name '*.c' -o -name '*.cpp' \) \
        ! -path './.git/*' \
        ! -path './bin/*' \
        -print0 | while IFS= read -r -d '' f; do
        sed -i 's/lwjgl3\.org/lwjgl.org/g' "$f"
    done
fi

echo "[preprocess] Package rename complete."

# ---- 6. gradle.properties: version from git describe -----------------------

GIT_VERSION=$(git describe --tags 2>/dev/null || echo "0.0.0-unknown")
echo "[preprocess] Setting version to: $GIT_VERSION"

sed -i "s/^lwjglVersion=.*/lwjglVersion=$GIT_VERSION/" gradle.properties

# ---- 7. build.gradle.kts: rewrite for cleanroommc publish ------------------
# We overwrite the entire file with a modified version since the changes are
# extensive (group, URL, credentials, signing removal, SNAPSHOT removal).

echo "[preprocess] Rewriting build.gradle.kts..."

cat > build.gradle.kts << 'GRADLE_EOF'
/*
 * Copyright LWJGL. All rights reserved.
 * License terms: https://www.lwjgl.org/license
 */
import java.net.URI

plugins {
    `java-platform`
    `maven-publish`
}

val lwjglVersion: String by project

defaultTasks = mutableListOf("publish")
layout.buildDirectory.set(layout.projectDirectory.dir("bin/MAVEN"))
group = "com.cleanroommc"

enum class BuildType {
    LOCAL,
    RELEASE
}

data class Deployment(
    val type: BuildType,
    val repo: URI,
    val version: String
)

val deployment = when {
    hasProperty("release") -> Deployment(
        type = BuildType.RELEASE,
        repo = uri("https://repo.cleanroommc.com/releases/"),
        version = lwjglVersion
    )
    else -> Deployment(
        type = BuildType.LOCAL,
        repo = repositories.mavenLocal().url,
        version = lwjglVersion
    )
}
version = deployment.version
println("${deployment.type.name} BUILD")

enum class Platforms(val classifier: String) {
    FREEBSD("natives-freebsd"),
    LINUX("natives-linux"),
    LINUX_ARM64("natives-linux-arm64"),
    LINUX_ARM32("natives-linux-arm32"),
    LINUX_PPC64LE("natives-linux-ppc64le"),
    LINUX_RISCV64("natives-linux-riscv64"),
    MACOS("natives-macos"),
    MACOS_ARM64("natives-macos-arm64"),
    WINDOWS("natives-windows"),
    WINDOWS_X86("natives-windows-x86"),
    WINDOWS_ARM64("natives-windows-arm64");

    companion object {
        val ALL = values()
    }
}

data class CustomArtifacts(
    val classifiersForBOM: List<String>,
    val publication: MavenPublication.() -> Unit
)

enum class Module(
    val artifact: String,
    val projectName: String,
    val projectDescription: String,
    vararg val platforms: Platforms,
    val custom: CustomArtifacts? = null
) {
    CORE("lwjgl", "LWJGL", "The LWJGL core library.", *Platforms.ALL, custom = CustomArtifacts(listOf("unsafe")) {
        artifact(CORE.artifact("unsafe")) {
            classifier = "unsafe"
        }
        artifact(CORE.artifact("unsafe-sources")) {
            classifier = "unsafe-sources"
        }
    }),
    ASSIMP(
        "lwjgl-assimp", "LWJGL - Assimp bindings",
        "A portable Open Source library to import various well-known 3D model formats in a uniform manner.",
        *Platforms.ALL
    ),
    BGFX(
        "lwjgl-bgfx", "LWJGL - bgfx bindings",
        "A cross-platform, graphics API agnostic rendering library. It provides a high performance, low level abstraction for common platform graphics APIs like OpenGL, Direct3D and Apple Metal.",
        Platforms.FREEBSD,
        Platforms.LINUX, Platforms.LINUX_ARM64, Platforms.LINUX_ARM32, Platforms.LINUX_PPC64LE, Platforms.LINUX_RISCV64,
        Platforms.MACOS, Platforms.MACOS_ARM64,
        Platforms.WINDOWS, Platforms.WINDOWS_X86
    ),
    EGL(
        "lwjgl-egl", "LWJGL - EGL bindings",
        "An interface between Khronos rendering APIs such as OpenGL ES or OpenVG and the underlying native platform window system."
    ),
    FMOD(
        "lwjgl-fmod", "LWJGL - FMOD bindings",
        "An end-to-end solution for adding sound and music to any game."
    ),
    FREETYPE(
        "lwjgl-freetype", "LWJGL - FreeType bindings",
        "A freely available software library to render fonts.",
        *Platforms.ALL
    ),
    GLFW(
        "lwjgl-glfw", "LWJGL - GLFW bindings",
        "A multi-platform library for OpenGL, OpenGL ES and Vulkan development on the desktop. It provides a simple API for creating windows, contexts and surfaces, receiving input and events.",
        *Platforms.ALL
    ),
    HARFBUZZ(
        "lwjgl-harfbuzz", "LWJGL - HarfBuzz bindings",
        "A text shaping library that allows programs to convert a sequence of Unicode input into properly formatted and positioned glyph output — for any writing system and language.",
        *Platforms.ALL
    ),
    HWLOC(
        "lwjgl-hwloc", "LWJGL - hwloc bindings",
        "A portable abstraction of the hierarchical topology of modern architectures, including NUMA memory nodes, sockets, shared caches, cores and simultaneous multithreading.",
        *Platforms.ALL
    ),
    JAWT(
        "lwjgl-jawt", "LWJGL - JAWT bindings",
        "The AWT native interface."
    ),
    JEMALLOC(
        "lwjgl-jemalloc", "LWJGL - jemalloc bindings",
        "A general purpose malloc implementation that emphasizes fragmentation avoidance and scalable concurrency support.",
        *Platforms.ALL
    ),
    KTX(
        "lwjgl-ktx", "LWJGL - KTX (Khronos Texture) bindings",
        "A lightweight container for textures for OpenGL®, Vulkan® and other GPU APIs.",
        Platforms.FREEBSD,
        Platforms.LINUX, Platforms.LINUX_ARM64, Platforms.LINUX_ARM32, Platforms.LINUX_PPC64LE, Platforms.LINUX_RISCV64,
        Platforms.MACOS, Platforms.MACOS_ARM64,
        Platforms.WINDOWS, Platforms.WINDOWS_ARM64
    ),
    LLVM(
        "lwjgl-llvm", "LWJGL - LLVM/Clang bindings",
        "A collection of modular and reusable compiler and toolchain technologies.",
        *Platforms.ALL
    ),
    LMDB(
        "lwjgl-lmdb", "LWJGL - LMDB bindings",
        "A compact, fast, powerful, and robust database that implements a simplified variant of the BerkeleyDB (BDB) API.",
        *Platforms.ALL
    ),
    LZ4(
        "lwjgl-lz4", "LWJGL - LZ4 bindings",
        "A lossless data compression algorithm that is focused on compression and decompression speed.",
        *Platforms.ALL
    ),
    MESHOPTIMIZER(
        "lwjgl-meshoptimizer", "LWJGL - meshoptimizer bindings",
        "A library that provides algorithms to help optimize meshes.",
        *Platforms.ALL
    ),
    MIMALLOC(
        "lwjgl-mimalloc", "LWJGL - mimalloc bindings",
        "A compact general purpose allocator with excellent performance.",
        *Platforms.ALL
    ),
    MSDFGEN(
        "lwjgl-msdfgen", "LWJGL - msdfgen bindings",
        "Multi-channel signed distance field generator.",
        *Platforms.ALL
    ),
    NANOVG(
        "lwjgl-nanovg", "LWJGL - NanoVG & NanoSVG bindings",
        "A small antialiased vector graphics rendering library for OpenGL. Also includes NanoSVG, a simple SVG parser.",
        *Platforms.ALL
    ),
    NFD(
        "lwjgl-nfd", "LWJGL - Native File Dialog bindings",
        "A small C library that portably invokes native file open, folder select and file save dialogs.",
        *Platforms.ALL
    ),
    NUKLEAR(
        "lwjgl-nuklear", "LWJGL - Nuklear bindings",
        "A minimal state immediate mode graphical user interface toolkit.",
        *Platforms.ALL
    ),
    ODBC(
        "lwjgl-odbc", "LWJGL - ODBC bindings",
        "A C programming language interface that makes it possible for applications to access data from a variety of database management systems (DBMSs)."
    ),
    OPENAL(
        "lwjgl-openal", "LWJGL - OpenAL bindings",
        "A cross-platform 3D audio API appropriate for use with gaming applications and many other types of audio applications.",
        *Platforms.ALL
    ),
    OPENCL(
        "lwjgl-opencl", "LWJGL - OpenCL bindings",
        "An open, royalty-free standard for cross-platform, parallel programming of diverse processors found in personal computers, servers, mobile devices and embedded platforms."
    ),
    OPENGL(
        "lwjgl-opengl", "LWJGL - OpenGL bindings",
        "The most widely adopted 2D and 3D graphics API in the industry, bringing thousands of applications to a wide variety of computer platforms.",
        *Platforms.ALL
    ),
    OPENGLES(
        "lwjgl-opengles", "LWJGL - OpenGL ES bindings",
        "A royalty-free, cross-platform API for full-function 2D and 3D graphics on embedded systems - including consoles, phones, appliances and vehicles.",
        *Platforms.ALL
    ),
    OPENXR(
        "lwjgl-openxr", "LWJGL - OpenXR bindings",
        "A royalty-free, open standard that provides high-performance access to Augmented Reality (AR) and Virtual Reality (VR)—collectively known as XR—platforms and devices.",
        Platforms.FREEBSD,
        Platforms.LINUX, Platforms.LINUX_ARM64, Platforms.LINUX_ARM32, Platforms.LINUX_PPC64LE, Platforms.LINUX_RISCV64,
        Platforms.WINDOWS, Platforms.WINDOWS_X86, Platforms.WINDOWS_ARM64
    ),
    OPUS(
        "lwjgl-opus", "LWJGL - Opus bindings",
        "A totally open, royalty-free, highly versatile audio codec.",
        *Platforms.ALL
    ),
    PAR(
        "lwjgl-par", "LWJGL - par_shapes bindings",
        "Generate parametric surfaces and other simple shapes.",
        *Platforms.ALL
    ),
    REMOTERY(
        "lwjgl-remotery", "LWJGL - Remotery bindings",
        "A realtime CPU/GPU profiler hosted in a single C file with a viewer that runs in a web browser.",
        Platforms.FREEBSD,
        Platforms.LINUX, Platforms.LINUX_ARM64, Platforms.LINUX_ARM32, Platforms.LINUX_PPC64LE, Platforms.LINUX_RISCV64,
        Platforms.MACOS, Platforms.MACOS_ARM64,
        Platforms.WINDOWS, Platforms.WINDOWS_X86
    ),
    RENDERDOC(
        "lwjgl-renderdoc", "LWJGL - RenderDoc bindings",
        "An API to control the RenderDoc debugger."
    ),
    RPMALLOC(
        "lwjgl-rpmalloc", "LWJGL - rpmalloc bindings",
        "A public domain cross platform lock free thread caching 16-byte aligned memory allocator implemented in C.",
        *Platforms.ALL
    ),
    SDL(
        "lwjgl-sdl", "LWJGL - SDL bindings",
        "Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware.",
        *Platforms.ALL
    ),
    SHADERC(
        "lwjgl-shaderc", "LWJGL - Shaderc bindings",
        "A collection of libraries for shader compilation.",
        *Platforms.ALL
    ),
    SPNG(
        "lwjgl-spng", "LWJGL - spng bindings",
        "libspng (simple png) is a C library for reading and writing Portable Network Graphics (PNG) format files with a focus on security and ease of use.",
        *Platforms.ALL
    ),
    SPVC(
        "lwjgl-spvc", "LWJGL - SPIRV-Cross bindings",
        "A library for performing reflection on SPIR-V and disassembling SPIR-V back to high level languages.",
        *Platforms.ALL
    ),
    STB(
        "lwjgl-stb", "LWJGL - stb bindings",
        "Single-file public domain libraries for fonts, images, ogg vorbis files and more.",
        *Platforms.ALL
    ),
    TINYEXR(
        "lwjgl-tinyexr", "LWJGL - Tiny OpenEXR bindings",
        "A small library to load and save OpenEXR(.exr) images.",
        *Platforms.ALL
    ),
    TINYFD(
        "lwjgl-tinyfd", "LWJGL - Tiny File Dialogs bindings",
        "Provides basic modal dialogs.",
        *Platforms.ALL
    ),
    VMA(
        "lwjgl-vma", "LWJGL - Vulkan Memory Allocator bindings",
        "An easy to integrate Vulkan memory allocation library.",
        *Platforms.ALL
    ),
    VULKAN(
        "lwjgl-vulkan", "LWJGL - Vulkan bindings",
        "A new generation graphics and compute API that provides high-efficiency, cross-platform access to modern GPUs used in a wide variety of devices from PCs and consoles to mobile phones and embedded platforms.",
        Platforms.MACOS, Platforms.MACOS_ARM64
    ),
    XXHASH(
        "lwjgl-xxhash", "LWJGL - xxHash bindings",
        "An extremely fast hash algorithm, running at RAM speed limits.",
        *Platforms.ALL
    ),
    YOGA(
        "lwjgl-yoga", "LWJGL - Yoga bindings",
        "An open-source, cross-platform layout library that implements Flexbox.",
        *Platforms.ALL
    ),
    ZSTD(
        "lwjgl-zstd", "LWJGL - Zstandard bindings",
        "A fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level and better compression ratios.",
        *Platforms.ALL
    );

    private fun directory(buildDir: String) = "./$buildDir/$artifact"

    private fun path() = "${directory("bin/MAVEN")}/$artifact"

    val isActive get() = File(directory("bin/RELEASE")).exists()

    fun hasArtifact(classifier: String) = File("${directory("bin/RELEASE")}/${artifact}-${classifier}.jar").exists()

    fun artifact(classifier: String? = null) =
        if (classifier === null)
            File("${path()}.jar").absoluteFile
        else
            File("${path()}-$classifier.jar").absoluteFile

}

fun PublishingExtension.setupRepository() {
    repositories {
        maven {
            url = deployment.repo

            if (deployment.type !== BuildType.LOCAL) {
                credentials {
                    username = System.getenv("CLEANROOM_USER") ?: ""
                    password = System.getenv("CLEANROOM_PWD") ?: ""
                }
            }
        }
    }
}

fun MavenPom.setupPom(pomName: String, pomDescription: String, pomPackaging: String) {
    name.set(pomName)
    description.set(pomDescription)
    url.set("https://www.lwjgl.org")
    packaging = pomPackaging

    scm {
        connection.set("scm:git:https://github.com/LWJGL/lwjgl3.git")
        developerConnection.set("scm:git:https://github.com/LWJGL/lwjgl3.git")
        url.set("https://github.com/LWJGL/lwjgl3.git")
    }

    licenses {
        license {
            name.set("BSD-3-Clause")
            url.set("https://www.lwjgl.org/license")
            distribution.set("repo")
        }
    }

    developers {
        developer {
            id.set("spasi")
            name.set("Ioannis Tsakpinis")
            email.set("iotsakp@gmail.com")
            url.set("https://github.com/Spasi")
        }
    }
}

Module.values().forEach { module ->
    project(":modules:lwjgl:${if (module === Module.CORE) "core" else module.artifact.removePrefix("lwjgl-")}") {
        group = rootProject.group
        version = rootProject.version
        layout.buildDirectory.set(rootProject.layout.projectDirectory.dir("bin/MAVEN/gradle/${module.artifact}"))

        plugins.apply("maven-publish")

        extensions.configure<PublishingExtension> {
            setupRepository()
            publications {
                if (module.isActive) {
                    val moduleVersion = deployment.version
                    create<MavenPublication>("maven${module.name}") {
                        artifactId = module.artifact
                        artifact(module.artifact())
                        if (module.custom != null) {
                            module.custom.publication(this)
                        }
                        if (deployment.type !== BuildType.LOCAL || module.hasArtifact("sources")) {
                            artifact(module.artifact("sources")) {
                                classifier = "sources"
                            }
                        }
                        if (deployment.type !== BuildType.LOCAL || module.hasArtifact("javadoc")) {
                            artifact(module.artifact("javadoc")) {
                                classifier = "javadoc"
                            }
                        }
                        module.platforms.forEach {
                            if (deployment.type !== BuildType.LOCAL || module.hasArtifact(it.classifier)) {
                                artifact(module.artifact(it.classifier)) {
                                    classifier = it.classifier
                                }
                            }
                        }

                        pom {
                            setupPom(module.projectName, module.projectDescription, "jar")

                            if (module != Module.CORE) {
                                withXml {
                                    asNode().appendNode("dependencies").apply {
                                        appendNode("dependency").apply {
                                            appendNode("groupId", "com.cleanroommc")
                                            appendNode("artifactId", "lwjgl")
                                            appendNode("version", moduleVersion)
                                            appendNode("scope", "compile")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

publishing {
    setupRepository()
    publications {
        val bomVersion = deployment.version
        create<MavenPublication>("lwjglBOM") {
            from(components["javaPlatform"])
            artifactId = "lwjgl-bom"

            pom {
                setupPom("LWJGL BOM", "LWJGL 3 Bill of Materials.", "pom")

                withXml {
                    asElement().getElementsByTagName("dependencyManagement").item(0).apply {
                        asElement().getElementsByTagName("dependencies").item(0).apply {
                            Module.values().forEach { module ->
                                val classifiers =
                                    (module.custom?.classifiersForBOM?.asSequence() ?: emptySequence()) +
                                    module.platforms.map { it.classifier }

                                classifiers.forEach {
                                    appendChild(
                                        ownerDocument
                                            .createElement("dependency")
                                            .apply {
                                                appendChild(
                                                    ownerDocument
                                                        .createElement("groupId")
                                                        .apply { textContent = "com.cleanroommc" }
                                                )
                                                appendChild(
                                                    ownerDocument
                                                        .createElement("artifactId")
                                                        .apply { textContent = module.artifact }
                                                )
                                                appendChild(
                                                    ownerDocument
                                                        .createElement("version")
                                                        .apply { textContent = bomVersion }
                                                )
                                                appendChild(
                                                    ownerDocument
                                                        .createElement("classifier")
                                                        .apply { textContent = it }
                                                )
                                            })
                                }
                            }
                        }
                    }

                    // Workaround for https://github.com/gradle/gradle/issues/7529
                    asNode()
                }
            }
        }
    }
}
tasks.named("publish") {
    dependsOn(project(":modules:lwjgl")
        .subprojects
        .map { it.tasks.named("publish") })
}

val copyArchives = tasks.register<Copy>("copyArchives") {
    from("bin/RELEASE")
    include("**")
    destinationDir = layout.buildDirectory.asFile.get()
}
allprojects {
    tasks.withType<GenerateMavenPom>().configureEach {
        dependsOn(copyArchives)
    }
    tasks.withType<PublishToMavenRepository>().configureEach {
        dependsOn(copyArchives)
    }
}

dependencies {
    constraints {
        Module.values().forEach { module ->
            api("com.cleanroommc:${module.artifact}:$version")
        }
    }
}
GRADLE_EOF

echo "[preprocess] build.gradle.kts rewritten."

# ---- 8. Clean generated sources ---------------------------------------------

echo "[preprocess] Cleaning generated sources..."
ant -emacs clean-generated -quiet 2>/dev/null || echo "[preprocess] Warning: ant clean-generated failed (ant may not be installed). Continuing."

# ---- 9. Summary -------------------------------------------------------------

echo ""
echo "[preprocess] ================================================"
echo "[preprocess] Preprocessing complete."
echo "[preprocess] Version: $GIT_VERSION"
echo "[preprocess] Group:   com.cleanroommc"
echo "[preprocess] Maven:   https://repo.cleanroommc.com/releases/"
echo "[preprocess] Signing: disabled"
echo "[preprocess] ================================================"
echo "[preprocess] Generated sources have been cleaned."
echo "[preprocess] Run 'ant compile-templates generate compile' to regenerate with org.lwjgl3 packages."