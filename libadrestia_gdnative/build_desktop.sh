#!/bin/bash
set -e

scons platform=$(./detect_platform.sh)
