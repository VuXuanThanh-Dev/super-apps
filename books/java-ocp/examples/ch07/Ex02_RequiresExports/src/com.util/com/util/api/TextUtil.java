package com.util.api;

import com.util.internal.Helper;

public class TextUtil {
    public static String shout(String s) { return Helper.clean(s).toUpperCase() + "!"; }
}
