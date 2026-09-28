module com.impl {
    requires com.api;
    provides com.api.Tax with com.impl.VatTax;
}
