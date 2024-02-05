name="linux-headers-tkg-eevdf-deb"
pkgver="$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)"

gives="linux-headers-$pkgver-tkg-eevdf"
url="https://github.com/Frogging-Family/linux-tkg/releases/download/v$pkgver/linux-headers-$pkgver-tkg-eevdf_$pkgver-1_amd64.deb"
hash="$(curl -sL https://github.com/Frogging-Family/linux-tkg/releases/download/v$pkgver/linux-headers-$pkgver-tkg-eevdf_$pkgver-1_amd64.deb |
    sha256sum |
    cut -d " " -f 1)"

pkgdesc="Linux headers tkg eevdf latest release"
arch=('amd64')
maintainer="xdavius <xdavius@github.com>"
