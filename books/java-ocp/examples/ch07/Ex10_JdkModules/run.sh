#!/usr/bin/env bash
# objective: 7.1, 7.2
# Các module của JDK: java.base là gốc; mọi module đều requires java.base ngầm.
source ./common.sh
echo "\$ java --list-modules | grep -E '^java\.(base|sql|logging|se)@'"
java --list-modules | grep -E '^java\.(base|sql|logging|se)@'
run java --describe-module java.sql
echo "\$ java --describe-module java.base | head -5"
java --describe-module java.base | head -5
