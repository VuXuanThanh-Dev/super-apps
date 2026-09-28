package com.app;
public class Main {
    public static void main(String[] args) {
        boolean present = ModuleLayer.boot().findModule("com.opt").isPresent();
        System.out.println(present ? com.opt.Extra.hi() : "optional absent");
    }
}
