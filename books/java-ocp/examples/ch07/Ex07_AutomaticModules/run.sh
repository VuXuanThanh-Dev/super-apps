#!/usr/bin/env bash
# objective: 7.2
# Migration: JAR không có module-info đặt trên MODULE PATH → automatic module; trên CLASSPATH → unnamed module.
source ./common.sh
run javac -d lib-out lib/org/json/lite/Json.java
mkdir -p mods
run jar --create --file mods/json-lite-1.2.jar -C lib-out .
run jar --describe-module --file mods/json-lite-1.2.jar
run javac -d out -p mods --module-source-path src -m com.report
run java -p mods:out -m com.report/com.report.Report
echo "--- cùng thư viện nhưng đặt trên classpath (unnamed module), chạy code không modular:"
cat > Plain.java <<'JAVA'
public class Plain {
    public static void main(String[] args) {
        System.out.println(org.json.lite.Json.whoAmI());
    }
}
JAVA
run javac -cp mods/json-lite-1.2.jar -d plain-out Plain.java
run java -cp mods/json-lite-1.2.jar:plain-out Plain
echo "--- đặt Automatic-Module-Name trong MANIFEST để chọn tên ổn định:"
printf 'Automatic-Module-Name: org.json.lite\n' > manifest.txt
run jar --create --file mods/json-lite-1.2.jar --manifest manifest.txt -C lib-out .
run jar --describe-module --file mods/json-lite-1.2.jar
