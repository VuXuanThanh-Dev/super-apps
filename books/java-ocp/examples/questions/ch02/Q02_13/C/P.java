public class P { enum E { X, Y, Z } public static void main(String[] a) {
    E e = E.Z;
    switch (e) { case X -> System.out.println("x"); }
    System.out.println("done"); } }
