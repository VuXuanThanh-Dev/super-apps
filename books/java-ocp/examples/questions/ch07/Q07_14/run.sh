unset JAVA_TOOL_OPTIONS
javac -d c app/com/legacy/Db.java && jar --create --file legacy.jar -C c . && jdeps --print-module-deps legacy.jar
