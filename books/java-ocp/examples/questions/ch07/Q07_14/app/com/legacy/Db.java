package com.legacy;
public class Db {
    public static void main(String[] args) {
        java.util.logging.Logger.getLogger("db").info("t=" + java.sql.DriverManager.getLoginTimeout());
    }
}
