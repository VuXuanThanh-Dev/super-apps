#!/usr/bin/env bash
# objective: 10.1
# ListResourceBundle (lớp Java) và thứ tự ưu tiên lớp > .properties.
source ./common.sh
run javac -d out Prices.java Prices_vi.java Main.java
cp *.properties out/
run java -cp out Main
