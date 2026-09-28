#!/usr/bin/env bash
# objective: 7.1
# requires + exports; và lỗi khi dùng package KHÔNG được export.
source ./common.sh
run javac -d out --module-source-path src -m com.util,com.app
run java -p out -m com.app/com.app.App
echo "--- dùng package com.util.internal (không export):"
mkdir -p bad-src && cp -r src/com.util bad-src/ && cp -r bad/com.app bad-src/
run javac -d out2 --module-source-path bad-src -m com.util,com.app
