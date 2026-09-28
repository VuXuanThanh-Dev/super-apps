package com.other;
public class Main {
    public static void main(String[] args) throws Exception {
        var f = com.m.model.Secret.class.getDeclaredField("code");
        try { f.setAccessible(true); System.out.println("com.other: " + f.get(new com.m.model.Secret())); }
        catch (RuntimeException e) { System.out.println("com.other: " + e.getClass().getSimpleName()); }
    }
}
