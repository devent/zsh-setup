#!/bin/bash
if [ -n "$http_proxy" ]; then
    echo -e "Acquire::http::Proxy \"$http_proxy\";"
fi
if [ -n "$http_proxy" ]; then
    echo -e "Acquire::ftp::Proxy \"$ftp_proxy\";"
fi
if [ -n "$http_proxy" ]; then
    echo -e "Acquire::https::Proxy \"$https_proxy\";"
fi
