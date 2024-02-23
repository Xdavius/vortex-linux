#!/bin/bash
pkgver=$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)

# ONE LINE HASH

url="full.tar.gz" ;\
hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"
