#!/usr/bin/env bash
# objective: 7.1
# requires transitive (implied readability).
source ./common.sh
run javac -d out --module-source-path src -m com.top
run java -p out -m com.top/com.top.Main
run java -p out --describe-module com.mid
