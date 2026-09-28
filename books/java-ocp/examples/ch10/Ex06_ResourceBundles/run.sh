#!/usr/bin/env bash
# objective: 10.1
# ResourceBundle dạng .properties: tìm theo thứ tự vi_VN → vi → (locale mặc định) → gốc.
source ./common.sh
run javac -d out Main.java
cp *.properties out/
run java -cp out Main
