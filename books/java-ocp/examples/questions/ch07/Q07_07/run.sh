unset JAVA_TOOL_OPTIONS
javac -d classes lib/org/util/Tool.java && mkdir -p mods && jar --create --file mods/my-utils-2.0.1.jar -C classes . && jar --describe-module --file mods/my-utils-2.0.1.jar | grep automatic | grep -v "No module"
