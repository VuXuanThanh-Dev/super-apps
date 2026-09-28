unset JAVA_TOOL_OPTIONS
javac -d c lib/org/u/U.java && jar --create --file my-lib-1.0.jar -C c . && jar --describe-module --file my-lib-1.0.jar | grep automatic | grep -v "No module"
