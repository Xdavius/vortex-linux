# Maintainer: Sven-Hendrik Haase <svenstaro@archlinux.org>
# Maintainer: Felix Yan <felixonmars@archlinux.org>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
name="nvidia-settings"
gives="nvidia-settings"
provides=("libxnvctrl0")
replace=("libxnvctrl-dev" "libxnvctrl0")
pkgname="nvidia-settings"
pkgver="545.29.06"
pkgrel="1"
pkgdesc='Tool for configuring the NVIDIA graphics driver'
url="https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${pkgver}.tar.gz"
arch=("amd64")
license=('GPL2')
makedepends=("inetutils-tools" "libjansson-dev" "libgtk-3-dev" "libxv-dev" "libvdpau-dev"  "libxext-dev" "libxxf86vm-dev" "m4")
depends=("wget" "libjansson-dev" "libgtk-3-dev" "libxv-dev" "libvdpau-dev" "libxext-dev")
replace=("nvidia-settings")
pacdeps=("nvidia-driver-bin")
options=('staticlibs')
maintainer="xdavius <xdavius@github.com>"

#hash=()

prepare() {

# PATCH
  wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-settings/-/raw/6762a119997dcec550242c24b24b7897e7490a9a/nvidia-settings-libxnvctrl_so.patch

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
  sudo make DESTDIR="${pkgdir}" install

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
