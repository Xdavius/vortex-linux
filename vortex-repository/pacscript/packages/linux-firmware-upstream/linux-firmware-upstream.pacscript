name="linux-firmware-upstream"
gives="linux-firmware-upstream"
pkgbase=linux-firmware
pkgname="linux-firmware"
pkgver=20240220
pkgrel=1
pkgdesc="Firmware files updates for Linux"

license=('GPL2' 'GPL3' 'custom')
arch=('any')
makedepends=('git' 'rdfind' 'python3-jinja2' 'debhelper-compat')
breaks=("amdgpu-dkms-firmware")
options=(!strip)

url="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/${pkgname}-${pkgver}.tar.gz"

maintainer="xdavius <xdavius@github.com>"
#hash=""

package() {

sudo make DESTDIR="${pkgdir}" FIRMWAREDIR=/usr/lib/firmware/updates install
}
