module com.mid {
    requires transitive com.base;   // ai requires com.mid cũng tự đọc được com.base
    exports com.mid;
}
