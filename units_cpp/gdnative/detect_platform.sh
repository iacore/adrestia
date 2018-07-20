#!/bin/bash

# Possible values: linux, windows, osx
# Windows not detected though lol
case "$(uname -s)" in
  Linux*) echo "linux";;
  Darwin*) echo "osx"  ;;
esac
