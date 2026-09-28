// objective: 10.1
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.GERMANY);
        // Tìm cho ja_JP: Labels_ja_JP → Labels_ja → (mặc định) Labels_de_DE → Labels_de → Labels (gốc)
        System.out.println("ja_JP, default de_DE -> " + ResourceBundle.getBundle("Labels", Locale.JAPAN).getString("title"));
        System.out.println("en_US, default de_DE -> " + ResourceBundle.getBundle("Labels", Locale.US).getString("title"));
        Locale.setDefault(Locale.JAPAN);
        System.out.println("fr_FR, default ja_JP -> " + ResourceBundle.getBundle("Labels", Locale.FRANCE).getString("title"));
        ResourceBundle.Control noFallback = ResourceBundle.Control.getNoFallbackControl(ResourceBundle.Control.FORMAT_DEFAULT);
        Locale.setDefault(Locale.GERMANY);
        System.out.println("ja_JP, no fallback -> " + ResourceBundle.getBundle("Labels", Locale.JAPAN, noFallback).getString("title"));
    }
}
