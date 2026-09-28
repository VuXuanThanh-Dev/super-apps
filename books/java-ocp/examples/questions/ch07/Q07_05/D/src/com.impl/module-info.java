module com.impl {
    requires com.api;
    provides com.impl.Hi with com.api.Greeter;
}
