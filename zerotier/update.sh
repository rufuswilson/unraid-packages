#!/bin/bash

vers = $(curl --silent "https://api.github.com/repos/zerotier/ZeroTierOne/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

curl "https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${vers}.tar.gz" --output "package.tar.gz"

tar -xf "package.tar.gz" -C "tmp"

cd tmp
