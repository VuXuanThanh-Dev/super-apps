package org.old;

public class Tool {
    public static void main(String[] args) {
        Module m = Tool.class.getModule();
        System.out.println("legacy tool, named module? " + m.isNamed() + " name=" + m.getName());
    }
}
