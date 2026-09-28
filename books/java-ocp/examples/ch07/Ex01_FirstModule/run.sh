#!/usr/bin/env bash
# objective: 7.1, 7.2
# Biên dịch và chạy một module đơn giản.
source ./common.sh
run javac -d out --module-source-path src -m com.greet
run find out -name "*.class" | sort
run java --module-path out --module com.greet/com.greet.Main
run java -p out -m com.greet/com.greet.Main
run java -p out --describe-module com.greet
