name="linux-image-tkg-eevdf-deb"
pkgver="$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)"

pkgrel="1"
gives="linux-image-${pkgver}-tkg-eevdf"
pacdeps=("linux-headers-tkg-eevdf-deb")
url="https://github.com/Frogging-Family/linux-tkg/releases/download/v${pkgver}/linux-image-${pkgver}-tkg-eevdf_${pkgver}-1_amd64.deb"
hash="$(curl -sL https://github.com/Frogging-Family/linux-tkg/releases/download/v${pkgver}/linux-image-${pkgver}-tkg-eevdf_${pkgver}-1_amd64.deb |
    sha256sum |
    cut -d " " -f 1)"

pkgdesc="Linux image tkg eevdf latest release"
arch=('amd64')
maintainer="xdavius <xdavius@github.com>"

#prepare() {

#pacstall -R linux-image-tkg-eevdf-deb linux-headers-tkg-eevdf-deb
#sudo apt purge linux-image-${pkgver}-tkg-eevdf linux-headers-${pkgver}-tkg-eevdf

#}
