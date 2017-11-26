#!/bin/sh -x

export ANDROID_HOME="${1}"
export ANDROID_NDK_ROOT="${2}"

GODOT_SOURCE_DIR="${3}"
cd $GODOT_SOURCE_DIR
scons p=android -j$(nproc) colored=yes tools=no target=release_debug
scons p=android -j$(nproc) colored=yes tools=no target=release

cd platform/android/java
./gradlew build
