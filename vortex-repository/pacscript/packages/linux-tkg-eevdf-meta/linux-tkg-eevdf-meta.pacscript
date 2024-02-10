name="linux-tkg-eevdf-meta"
pkgver="$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)"

pkgrel="2"
gives="${name}"
pacdeps=("linux-headers-tkg-eevdf-deb" "linux-image-tkg-eevdf-deb")
url="https://github.com/oklopfer/debs/raw/master/empty.tar.xz"
pkgdesc="Linux tkg eevdf Metapackage latest release"
arch=('amd64')
maintainer="xdavius <xdavius@github.com>"
