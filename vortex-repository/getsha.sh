#!/bin/bash
pkgver=$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)

url="https://us.download.nvidia.com/XFree86/Linux-x86_64/${pkgver}/${_pkg}.run"
hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"
