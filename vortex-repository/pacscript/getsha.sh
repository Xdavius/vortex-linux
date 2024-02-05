#!/bin/bash
pkgver=$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)

t=$(mktemp) && \
wget 'https://github.com/Frogging-Family/linux-tkg/releases/download/v$pkgver/linux-headers-$pkgver-tkg-eevdf_$pkgver-1_amd64.deb' -qO "$t" && \
sha256sum "$t"

testcurl=$(curl -s curl -s https://github.com/Frogging-Family/linux-tkg/releases/download/v$pkgver/linux-headers-$pkgver-tkg-eevdf_$pkgver-1_amd64.deb | sha256sum | cut -d " " -f 1|sha256sum|cut -d " " -f 1)


echo $t
echo $testcurl
