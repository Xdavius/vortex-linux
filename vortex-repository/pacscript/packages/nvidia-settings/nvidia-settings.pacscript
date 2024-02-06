# Maintainer: Sven-Hendrik Haase <svenstaro@archlinux.org>
# Maintainer: Felix Yan <felixonmars@archlinux.org>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
name="nvidia-settings"
gives=("nvidia-settings" "libxnvctrl")
replace=("nvidia-settings" "libxnvctrl")
pkgbase="nvidia-settings"
pkgname="nvidia-settings"
pkgver="545.29.06"
pkgrel="1"
pkgdesc='Tool for configuring the NVIDIA graphics driver'
url="${pkgbase}-${pkgver}.tar.gz::https://github.com/NVIDIA/nvidia-settings/archive/${pkgver}.tar.gz"
arch=("amd64")
license=('GPL2')
makedepends=('inetutils' 'jansson' 'gtk3' 'libxv' 'libvdpau' 'nvidia-utils' 'libxext')
depends=('jansson' 'gtk3' 'libxv' 'libvdpau' 'nvidia-utils' 'libxnvctrl' 'libxext')
options=('staticlibs')

#hash=()

prepare() {
  export PREFIX=/usr
  export NV_USE_BUNDLED_LIBJANSSON=0
  export OUTPUTDIR=out

  cd ${pkgbase}-${pkgver}

  #PATCH
  wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-settings/-/blob/6762a119997dcec550242c24b24b7897e7490a9a/nvidia-settings-libxnvctrl_so.patch
  patch -Np1 -i "${srcdir}"/nvidia-settings-libxnvctrl_so.patch
}

build() {
  cd ${pkgbase}-${pkgver}
  export CFLAGS+=" -ffat-lto-objects"
  make -j{ncpu}
}

package() {

  cd ${pkgbase}-${pkgver}
  DESTDIR="${pkgdir}" sudo make install

  sudo install -D -m644 doc/nvidia-settings.desktop "${pkgdir}/usr/share/applications/nvidia-settings.desktop"
  sudo install -D -m644 doc/nvidia-settings.png "${pkgdir}/usr/share/pixmaps/nvidia-settings.png"
  sudo sed \
    -e 's:__UTILS_PATH__:/usr/bin:' \
    -e 's:__PIXMAP_PATH__:/usr/share/pixmaps:' \
    -e 's/__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__/Settings;HardwareSettings;/' \
    -e 's/Icon=.*/Icon=nvidia-settings/' \
    -i "${pkgdir}/usr/share/applications/nvidia-settings.desktop"

  #cd ${pkgbase}-${pkgver}
  sudo install -Dm 644 doc/{NV-CONTROL-API.txt,FRAMELOCK.txt} -t "${pkgdir}/usr/share/doc/${pkgname}"
  sudo install -Dm 644 samples/{Makefile,README,*.c,*.h,*.mk} -t "${pkgdir}/usr/share/doc/${pkgname}/samples"

  sudo install -Dm 644 src/libXNVCtrl/*.h -t "${pkgdir}/usr/include/NVCtrl"
  sudo install -d "${pkgdir}/usr/lib"
  sudo cp -Pr src/out/libXNVCtrl.* -t "${pkgdir}/usr/lib"
}

# vim: ts=2 sw=2 et:
