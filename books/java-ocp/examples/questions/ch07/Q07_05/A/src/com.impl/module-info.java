module com.impl {
    requires com.api;
    provides com.api.Greeter with com.impl.Hi;
}
