name="libstrangle"
pkgname="libstrangle"
pkgver=6020f9e
# get pkgver with :
# git rev-list --count HEAD
# git rev-parse --short HEAD
pkgrel=1
url="https://github.com/milaq/libstrangle/archive/refs/heads/master.zip"
pkgdesc="Simple FPS Limiter"
repology=("project: libstrangle")
arch=('amd64')
maintainer="Cavern"

build() {
    patch -p1 -i "archlinux/00-defer-ldconfig.patch"
    patch -p1 -i "archlinux/01-fix-prefix.patch"
    make
}

package() {
    sudo DESTDIR=${pkgdir} make install
}
