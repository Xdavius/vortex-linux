pkgname=arch-install-scripts
gives=arch-install-scripts
pkgver=28
pkgrel=1
pkgdesc="Scripts to aid in installing Arch Linux"
arch=('any')
source=("https://github.com/archlinux/arch-install-scripts")
license=('GPL2')
depends=('awk' 'bash' 'coreutils' 'grep' 'util-linux')
makedepends=('asciidoc' 'git')
source=("https://github.com/archlinux/arch-install-scripts/archive/refs/tags/v${pkgver}.tar.gz")

build() {
  cd "${_archive}"
  make -j"${NCPU}"
  make check
}

package() {
  cd "${_archive}"
 make PREFIX=/usr DESTDIR="${pkgdir}" install
}

