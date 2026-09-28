package com.inspect;

import com.model.Secret;
import java.lang.reflect.Field;

public class Main {
    public static void main(String[] args) throws Exception {
        Secret s = new Secret();
        System.out.println(s.hint());
        Field f = Secret.class.getDeclaredField("code");
        try {
            f.setAccessible(true);                          // đòi hỏi package phải được "opens"
            System.out.println("private code = " + f.get(s));
        } catch (RuntimeException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
