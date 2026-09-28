#!/usr/bin/env bash
# objective: 7.1
# Service: interface (api) + provider (provides ... with ...) + consumer (uses + ServiceLoader).
source ./common.sh
run javac -d out --module-source-path src -m com.shop.api,com.shop.vnpay,com.shop.app
echo "--- chạy KHÔNG có provider trên module path:"
mkdir -p only && cp -r out/com.shop.api out/com.shop.app only/
run java -p only -m com.shop.app/com.shop.app.Checkout
echo "--- chạy CÓ provider:"
run java -p out -m com.shop.app/com.shop.app.Checkout
run java -p out --describe-module com.shop.vnpay
