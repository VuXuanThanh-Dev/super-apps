package org.json.lite;

// Thư viện "cũ" không có module-info.java
public class Json {
    public static String quote(String s) { return "\"" + s + "\""; }
    public static String whoAmI() {
        Module m = Json.class.getModule();
        return "Json is in module: " + (m.isNamed() ? m.getName() : "UNNAMED");
    }
}
