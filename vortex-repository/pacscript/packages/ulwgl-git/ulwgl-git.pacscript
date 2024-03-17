name="ulwgl-git"
pkgname="ulwgl-git"
pkgver="0.1.RC3"
pkgrel=1
url="https://github.com/Open-Wine-Components/ULWGL-launcher.git"
makedepends=("git" "make")
pkgdesc="Unified launcher for Windows games on Linux in progress using Steam Runtime Tools, independent of Steam."
repology=("project: ulwgl")
arch=('amd64')
maintainer="Cavern"

build() {
    git submodule update --init
    ./configure.sh --prefix=/usr
    make
}

package() {
    sudo "DESTDIR=${pkgdir}" make install
}
