#!/usr/bin/env bash
# objective: 7.2
# jlink: tạo runtime image nhỏ chỉ chứa các module cần thiết.
source ./common.sh
run javac -d out --module-source-path src -m com.hello
run jlink --module-path out --add-modules com.hello --output image --strip-debug --no-header-files --no-man-pages
run image/bin/java --list-modules
run image/bin/java -m com.hello/com.hello.Hello
echo "\$ ls image"
ls image | sort
