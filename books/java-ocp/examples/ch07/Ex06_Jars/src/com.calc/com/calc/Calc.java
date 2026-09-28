package com.calc;

public class Calc {
    public static int add(int a, int b) { return a + b; }
    public static void main(String[] args) {
        System.out.println("2 + 3 = " + add(2, 3) + " (module " + Calc.class.getModule().getName() + ")");
    }
}
