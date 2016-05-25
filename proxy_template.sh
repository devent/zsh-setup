#!/bin/bash
cat <<EOT
export http_proxy="$http_proxy"
export https_proxy="$https_proxy"
export ftp_proxy="$ftp_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export FTP_PROXY="$ftp_proxy"
EOT
