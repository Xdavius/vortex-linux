pkgname="nvidia-settings"
gives="nvidia-settings"
pkgdesc='Tool for configuring the NVIDIA graphics driver'
pkgver="545.29.06"
pkgrel="1"

makedepends=("wget" "inetutils-tools" "libjansson-dev" "libgtk-3-dev" "libvdpau-dev" "libxv-dev" "libxext-dev" "libxxf86vm-dev" "m4")
pacdeps=("nvidia-driver-functionality-dkms-bundle")
optdepends=("vdpauinfo: Show VDPAU Opencl Info")
provides=("libxnvctrl0" "nvidia-settings")
replaces=("libxnvctrl0" "nvidia-settings" "nvidia-driver-production-dkms-bundle" "nvidia-driver-beta-dkms-bundle")

incompatible=('ubuntu:*')

source=("https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${pkgver}.tar.gz")
arch=("amd64")
license=('GPL2')

options=('staticlibs')

maintainer=("xdavius <xdavius@github.com>")

sha256sums=("SKIP")
external_connection="true"

prepare() {
  cd "${_archive}"

# PATCHES

  patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/nvidia-settings"

  wget ${patches_url}/nvidia-settings-libxnvctrl_so.patch

  patch -Np1 -i "nvidia-settings-libxnvctrl_so.patch"
}

build() {
  cd "${_archive}"

  export PREFIX=/usr
  export NV_USE_BUNDLED_LIBJANSSON=0
  export OUTPUTDIR=out
  export CFLAGS+=" -ffat-lto-objects"
  
  make -j"${NCPU}"
}

package() {
  cd "${_archive}"

  export PREFIX=/usr
  make PREFIX=/usr DESTDIR="${pkgdir}" install

  install -D -m644 doc/nvidia-settings.desktop "${pkgdir}/usr/share/applications/nvidia-settings.desktop"
  install -D -m644 doc/nvidia-settings.png "${pkgdir}/usr/share/pixmaps/nvidia-settings.png"
  sed \
    -e 's:__UTILS_PATH__:/usr/bin:' \
    -e 's:__PIXMAP_PATH__:/usr/share/pixmaps:' \
    -e 's/__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__/Settings;HardwareSettings;/' \
    -e 's/Icon=.*/Icon=nvidia-settings/' \
    -i "${pkgdir}/usr/share/applications/nvidia-settings.desktop"

  install -Dm 644 doc/{NV-CONTROL-API.txt,FRAMELOCK.txt} -t "${pkgdir}/usr/share/doc/${gives}"
  install -Dm 644 samples/{Makefile,README,*.c,*.h,*.mk} -t "${pkgdir}/usr/share/doc/${gives}/samples"

  install -Dm 644 src/libXNVCtrl/*.h -t "${pkgdir}/usr/include/NVCtrl"
  install -d "${pkgdir}/usr/lib/"
  cp -Pr src/out/libXNVCtrl.* -t "${pkgdir}/usr/lib/"

}

# vim: ts=2 sw=2 et:
