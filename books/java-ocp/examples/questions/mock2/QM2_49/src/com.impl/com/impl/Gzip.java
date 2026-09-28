package com.impl;
public class Gzip implements com.api.Codec {
    private final int level;
    public Gzip(int level) { this.level = level; }
    public String name() { return "gzip" + level; }
}
