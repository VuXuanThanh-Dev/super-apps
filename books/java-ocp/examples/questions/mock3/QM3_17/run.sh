unset JAVA_TOOL_OPTIONS
javac -d c src/com/x/Main.java && jar --create --file app.jar -C c . && java -cp app.jar com.x.Main
