name=arch-install-scripts
pkgname=arch-install-scripts
pkgver=28
pkgrel=1
pkgdesc="Scripts to aid in installing Arch Linux"
arch=('any')
url="https://github.com/archlinux/arch-install-scripts"
license=('GPL2')
depends=('awk' 'bash' 'coreutils' 'grep' 'util-linux')
makedepends=('asciidoc' 'git')
url="https://github.com/archlinux/arch-install-scripts/archive/refs/tags/v${pkgver}.tar.gz"

build() {
  make -j"${NCPU}"
  make check
}

package() {
 sudo make PREFIX=/usr DESTDIR="${pkgdir}" install
}

