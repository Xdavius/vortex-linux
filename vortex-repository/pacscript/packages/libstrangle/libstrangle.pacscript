# Maintainer: core_contingency <ccontingency(at)gmail(dot)com>
# Maintainer: Quentin Bouvet <qbouvet[at]outlook(dot)com>
# Contributor: ScarecrowDM <diego(dot)busnelli@hotmail(dot)com>
# Contributor: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
# Contributor: pyamsoft <pyam(dot)soft(at)gmail(dot)com>
name="libstrangle"
pkgname="libstrangle"
pkgdesc="Simple FPS Limiter"
pkgver=0.1.1
pkgrel=1

arch=('amd64')
depends=("glibc-2.0-dev:i386" "libglvnd-dev:i386")
makedepends=('git' 'libx11-dev' 'mesa-common-dev' 'crossbuild-essential-i386' 'libglib2.0-dev:i386' )
gives=('libstrangle')
conflicts=('libstrangle')
license=('GPL3')

url="https://gitlab.com/torkel104/libstrangle/-/archive/${pkgver}/${pkgname}-${pkgver}.tar.gz"

hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

prepare() {
    cd ${pkgname}-${pkgver}
    sed -i -e '/ldconfig/d' makefile
    patch -p2 < ../fix-compilation-gcc13.patch
    patch -p2 < ../bump-vulkan-version.patch
    patch -p2 < ../find-dlsym.patch
}

build() {
    #cd ${pkgname}-${pkgver}
    make prefix=/usr
}

package() {
    #cd ${pkgname}-${pkgver]
    make prefix=/usr DESTDIR="${pkgdir}" install-common install-32 install-64 install-ld

    # Install the README.md locally
    install -d "${pkgdir}/usr/share/doc/${pkgname}"
    install -m644 -t "${pkgdir}/usr/share/doc/${pkgname}" README.*
}

post_install() {
  ldconfig
}

post_upgrade() {
  post_install
}
