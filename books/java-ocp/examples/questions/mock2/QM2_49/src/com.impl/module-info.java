module com.impl {
    requires com.api;
    provides com.api.Codec with com.impl.Gzip;
}
