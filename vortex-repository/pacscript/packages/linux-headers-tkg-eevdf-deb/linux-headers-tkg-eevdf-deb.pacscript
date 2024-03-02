name="linux-headers-tkg-eevdf-deb"
pkgver="$(curl --silent "https://api.github.com/repos/xdavius/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')"

pkgrel="1"
gives="linux-headers-${pkgver}-tkg-eevdf"
url="https://github.com/xdavius/linux-tkg/releases/download/${pkgver}/linux-headers-${pkgver}-tkg-eevdf_${pkgver}-1_amd64.deb"

pkgdesc="Linux headers tkg eevdf latest release"
arch=('amd64')
maintainer="xdavius <xdavius@github.com>"
