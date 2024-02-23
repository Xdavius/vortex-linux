# Maintainer: Sven-Hendrik Haase <svenstaro@archlinux.org>
# Maintainer: Felix Yan <felixonmars@archlinux.org>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
name="nvidia-settings"
gives="nvidia-settings"
pkgdesc='Tool for configuring the NVIDIA graphics driver'
pkgname="nvidia-settings"
pkgver="545.29.06"
pkgrel="1"

makedepends=("wget" "inetutils-tools" "libjansson-dev" "libgtk-3-dev" "libvdpau-dev" "libxv-dev" "libxext-dev" "libxxf86vm-dev" "m4")
pacdeps=("nvidia-driver-functionality-dkms-bundle")
optdepends=("vdpauinfo: Show VDPAU Opencl Info")
provides=("libxnvctrl0" "nvidia-settings")
replace=("libxnvctrl0" "nvidia-settings" "nvidia-driver-production-dkms-bundle" "nvidia-driver-beta-dkms-bundle")

incompatible=('ubuntu:*')

url="https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${pkgver}.tar.gz"
arch=("amd64")
license=('GPL2')

options=('staticlibs')

maintainer="xdavius <xdavius@github.com>"

hash="$(curl -sL ${url} |
    sha256sum |
    cut -d " " -f 1)"

prepare() {

# PATCHES

  patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/nvidia-settings"

  wget ${patches_url}/nvidia-settings-libxnvctrl_so.patch

  patch -Np1 -i "nvidia-settings-libxnvctrl_so.patch"
}

build() {

  export PREFIX=/usr
  export NV_USE_BUNDLED_LIBJANSSON=0
  export OUTPUTDIR=out
  export CFLAGS+=" -ffat-lto-objects"
  
  make -j"${NCPU}"
}

package() {

  export PREFIX=/usr
  sudo make PREFIX=/usr DESTDIR="${pkgdir}" install

  sudo install -D -m644 doc/nvidia-settings.desktop "${pkgdir}/usr/share/applications/nvidia-settings.desktop"
  sudo install -D -m644 doc/nvidia-settings.png "${pkgdir}/usr/share/pixmaps/nvidia-settings.png"
  sudo sed \
    -e 's:__UTILS_PATH__:/usr/bin:' \
    -e 's:__PIXMAP_PATH__:/usr/share/pixmaps:' \
    -e 's/__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__/Settings;HardwareSettings;/' \
    -e 's/Icon=.*/Icon=nvidia-settings/' \
    -i "${pkgdir}/usr/share/applications/nvidia-settings.desktop"

  sudo install -Dm 644 doc/{NV-CONTROL-API.txt,FRAMELOCK.txt} -t "${pkgdir}/usr/share/doc/${pkgname}"
  sudo install -Dm 644 samples/{Makefile,README,*.c,*.h,*.mk} -t "${pkgdir}/usr/share/doc/${pkgname}/samples"

  sudo install -Dm 644 src/libXNVCtrl/*.h -t "${pkgdir}/usr/include/NVCtrl"
  sudo install -d "${pkgdir}/usr/lib/"
  sudo cp -Pr src/out/libXNVCtrl.* -t "${pkgdir}/usr/lib/"

}

# vim: ts=2 sw=2 et:
