name="linux-image-tkg-eevdf-deb"
pkgver="$(curl --silent "https://api.github.com/repos/xdavius/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')"

pkgrel="1"
gives="linux-image-${pkgver}-tkg-eevdf"
pacdeps=("linux-headers-tkg-eevdf-deb")
url="https://github.com/xdavius/linux-tkg/releases/download/${pkgver}/linux-image-${pkgver}-tkg-eevdf_${pkgver}-1_amd64.deb"

pkgdesc="Linux image tkg eevdf latest release"
arch=('amd64')
maintainer="xdavius <xdavius@github.com>"
