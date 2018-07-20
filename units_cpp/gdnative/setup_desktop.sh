#!/bin/bash

# Possible values: linux, windows, osx
PLATFORM=linux

# Pull in dependencies. See setup_android.sh for details.
git submodule update

# Build it! The resulting static library will be put in godot-cpp/bin/, and
# will be named something like "libgodot-cpp.linux.64.a".
(cd godot-cpp && scons platform=$PLATFORM)
