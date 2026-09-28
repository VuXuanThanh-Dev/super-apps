module com.p { requires com.api; exports com.p; provides com.p.Impl with com.api.Svc; }
