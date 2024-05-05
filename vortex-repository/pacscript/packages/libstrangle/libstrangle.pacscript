# Maintainer: core_contingency <ccontingency(at)gmail(dot)com>
# Maintainer: Quentin Bouvet <qbouvet[at]outlook(dot)com>
# Contributor: ScarecrowDM <diego(dot)busnelli@hotmail(dot)com>
# Contributor: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
# Contributor: pyamsoft <pyam(dot)soft(at)gmail(dot)com>
pkgname="libstrangle"
gives="libstrangle"
pkgdesc="Simple FPS Limiter"
pkgver=0.1.1
pkgrel=1
arch=('amd64')

provides=(libstrangle:i386)
makedepends=('git' 'libx11-dev' 'mesa-common-dev' 'crossbuild-essential-i386' 'libglib2.0-dev:i386' 'g++-multilib')
depends=("glibc-2.0-dev:i386" "libglvnd-dev:i386" "glibc-2.0-dev" "libglvnd-dev")
breaks=('libstrangle')

license=('GPL3')

source=("https://gitlab.com/torkel104/libstrangle/-/archive/${pkgver}/${gives}-${pkgver}.tar.gz")

sha256sums=("$(curl -sL $url | sha256sum | cut -d " " -f 1)")

prepare() {
  cd "${_archive}"

# ADD I386 ARCHITECTURE
    dpkg --add-architecture i386
    apt update
    
    patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/libstrangle"

    wget ${patches_url}/fix-compilation-gcc13.patch
    wget ${patches_url}/bump-vulkan-version.patch
    wget ${patches_url}/find-dlsym.patch

    sed -i -e '/ldconfig/d' makefile
    patch -p2 < fix-compilation-gcc13.patch
    patch -p2 < bump-vulkan-version.patch
    patch -p2 < find-dlsym.patch
}

build() {
  cd "${_archive}"
    
    make prefix=/usr
}

package() {
  cd "${_archive}"
    
    make prefix=/usr DESTDIR="${pkgdir}" install-common install-32 install-64 install-ld

    # Install the README.md locally
    install -d "${pkgdir}/usr/share/doc/${gives}"
    install -m644 -t "${pkgdir}/usr/share/doc/${gives}" README.*
}

post_install() {
  ldconfig
}

post_upgrade() {
  post_install
}
