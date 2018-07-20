#!/bin/bash
set -e

# First, we pull in `godot_headers` and `godot-cpp` as submodules.
# `godot_headers` provides the gdnative C api. If you have the godot source
# code, it is pretty much the same as what is located at
# `modules/gdnative/include`. `godot-cpp` is a layer that makes it easier to
# write idiomatic C++ code for gdnative.
git submodule update --init
godot --gdnative-generate-json-api godot-cpp/godot_api.json

# Build it! The resulting static library will be put in godot-cpp/bin/, and
# will be named something like "libgodot-cpp.linux.64.a".
(cd godot-cpp && scons platform=$(../detect_platform.sh) headers=../godot_headers -j$(nproc --ignore=1) generate_bindings=yes)
