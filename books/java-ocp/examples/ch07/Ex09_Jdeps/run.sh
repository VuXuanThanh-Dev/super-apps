#!/usr/bin/env bash
# objective: 7.2
# jdeps: xem JAR phụ thuộc module nào của JDK (bước đầu khi chuyển sang module).
source ./common.sh
run javac -d app-out app/com/legacy/Db.java
run jar --create --file legacy.jar -C app-out .
run jdeps -summary legacy.jar
run jdeps --list-deps legacy.jar
run jdeps --print-module-deps legacy.jar
