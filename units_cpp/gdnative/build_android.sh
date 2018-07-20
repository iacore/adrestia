#!/bin/bash
set -e

# We also use `ndk-build` to build our library. The configs in the jni/ folder
# tell ndk-build to link against the static libraries in godot-cpp-libs/ that
# we generated with `./setup_android.sh`.
ndk-build

# We copy the resulting dynamic libraries to bin/ to make them visible to
# Godot.
for dir in libs/*/; do
  platform=$(basename $dir)
  mkdir -p bin/$platform
  cp libs/$platform/*.so bin/android/$platform/
done
