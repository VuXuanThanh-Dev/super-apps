package com.legacy;

import java.sql.DriverManager;
import java.util.logging.Logger;

public class Db {
    static final Logger LOG = Logger.getLogger("db");
    public static void main(String[] args) {
        int timeout = DriverManager.getLoginTimeout();   // dùng một lớp của java.sql
        LOG.fine("timeout " + timeout);
        System.out.println("needs java.sql and java.logging");
    }
}
