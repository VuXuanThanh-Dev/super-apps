#!/usr/bin/env bash
# objective: 7.2
# Tạo JAR modular (có module-info.class) và JAR thường (non-modular), rồi chạy.
source ./common.sh
run javac -d out/com.calc src/com.calc/module-info.java src/com.calc/com/calc/Calc.java
mkdir -p mods
run jar --create --file mods/calc.jar --main-class com.calc.Calc -C out/com.calc .
run jar --describe-module --file mods/calc.jar
run java -p mods -m com.calc                     # có Main-Class nên không cần ghi tên lớp
echo "--- JAR non-modular chạy trên classpath:"
run javac -d legacy-out legacy/org/old/Tool.java
run jar --create --file tool.jar -C legacy-out .
run java -cp tool.jar org.old.Tool
run jar --list --file mods/calc.jar
