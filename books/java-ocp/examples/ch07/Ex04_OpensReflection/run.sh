#!/usr/bin/env bash
# objective: 7.1
# exports vs opens: reflection sâu (private) cần "opens".
source ./common.sh
run javac -d out --module-source-path src -m com.model,com.inspect
echo "--- chỉ exports:"
run java -p out -m com.inspect/com.inspect.Main
echo "--- thêm 'opens com.model;' vào module-info của com.model:"
sed -i 's|// "opens com.model;".*|opens com.model;|' src/com.model/module-info.java
run cat src/com.model/module-info.java
run javac -d out --module-source-path src -m com.model,com.inspect
run java -p out -m com.inspect/com.inspect.Main
