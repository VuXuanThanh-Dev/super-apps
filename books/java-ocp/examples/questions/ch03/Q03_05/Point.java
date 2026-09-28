record Point(int x, int y) {
    static int count;                       // L1
    int z;                                  // L2
    Point {
        if (x < 0) x = 0;                   // L3
    }
    public int x() { return x; }            // L4
    void reset() { this.y = 0; }            // L5

    public static void main(String[] args) { }
}
