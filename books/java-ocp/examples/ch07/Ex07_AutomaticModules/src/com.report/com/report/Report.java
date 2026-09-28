package com.report;

import org.json.lite.Json;

public class Report {
    public static void main(String[] args) {
        System.out.println(Json.quote("report") + " | " + Json.whoAmI());
    }
}
