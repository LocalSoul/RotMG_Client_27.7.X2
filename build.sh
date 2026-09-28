#!/usr/bin/env bash
set -euo pipefail

SDK="${FLEX_HOME:-/home/max/flex-sdk-4.9.1}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$PROJECT_DIR/bin-debug"

"$SDK/bin/mxmlc" \
    -compiler.strict=true \
    -compiler.show-actionscript-warnings=false \
    -locale=en_US \
    -default-size 800 600 \
    -default-frame-rate=60 \
    -default-background-color=#000000 \
    -target-player=15.0 \
    -swf-version=15 \
    -compiler.optimize=true \
    -use-direct-blit=true \
    -compiler.keep-as3-metadata=Inject,Embed,PostConstruct,ArrayElementType \
    -source-path+=src \
    -library-path+=libs \
    -output="$PROJECT_DIR/bin-debug/WebMain.swf" \
    "$PROJECT_DIR/src/WebMain.as"