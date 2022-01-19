#!/bin/bash

vers = $(curl --silent "https://api.github.com/repos/zerotier/ZeroTierOne/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

wget "https://api.github.com/repos/zerotier/ZeroTierOne/tarball/${vers}" -O "package.tar.gz"

mkdir "tmp"
tar -xzf "package.tar.gz" --directory "tmp"

cd tmp/zerotier-ZeroTierOne-*

make-linux -j$(nproc) one

cp zerotier-one ../

cd ..
