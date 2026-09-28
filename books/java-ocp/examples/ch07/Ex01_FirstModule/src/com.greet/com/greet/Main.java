package com.greet;

public class Main {
    public static void main(String[] args) {
        Module m = Main.class.getModule();
        System.out.println("Hello from module " + m.getName());
        System.out.println("named? " + m.isNamed() + ", requires java.logging? "
                + m.getDescriptor().requires().stream().anyMatch(r -> r.name().equals("java.logging")));
    }
}
