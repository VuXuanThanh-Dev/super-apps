#!/usr/bin/env bash
# objective: 7.1
# Lỗi hay gặp: vòng phụ thuộc (cycle) giữa các module; requires module không tồn tại; chạy module không có trên path.
source ./common.sh
run javac -d out1 --module-source-path cycle -m mod.a,mod.b
run javac -d out2 --module-source-path missing -m mod.c
run java -p out1 -m mod.a/a.A
