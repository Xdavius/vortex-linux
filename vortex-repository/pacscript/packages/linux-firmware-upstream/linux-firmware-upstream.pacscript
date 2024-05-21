pkgname="linux-firmware-upstream"
gives="linux-firmware-upstream"
pkgbase=linux-firmware
pkgver=20240220
pkgrel=1
pkgdesc="Firmware files updates for Linux"

license=('GPL2' 'GPL3' 'custom')
arch=('any')
makedepends=('git' 'rdfind' 'python3-jinja2' 'debhelper-compat')
breaks=("amdgpu-dkms-firmware")
options=(!strip)

source=("https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/${gives}-${pkgver}.tar.gz")

maintainer=("xdavius <xdavius@github.com>")
#hash=""

package() {
  cd "${_archive}"

make DESTDIR="${pkgdir}" FIRMWAREDIR=/usr/lib/firmware/updates install
}
