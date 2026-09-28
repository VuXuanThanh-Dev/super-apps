#!/usr/bin/env bash
# objective: 10.1
# Vai trò của locale mặc định khi không tìm thấy bundle cho locale được yêu cầu.
source ./common.sh
run javac -d out Main.java
cp *.properties out/
run java -cp out Main
