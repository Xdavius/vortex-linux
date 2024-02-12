#!/bin/bash
pkgver=$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)

hash="$(curl -sL https://github.com/Frogging-Family/linux-tkg/releases/download/v${pkgver}/linux-image-${pkgver}-tkg-eevdf_${pkgver}-1_amd64.deb |
    sha256sum |
    cut -d " " -f 1)"

echo $hash
