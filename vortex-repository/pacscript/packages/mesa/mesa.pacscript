pkgname="mesa"
#gives="mesa"
pkgver="24.0.2"
pkgrel=1
source=("https://mesa.freedesktop.org/archive/mesa-${pkgver}.tar.xz")
#url="https://launchpad.net/~kisak/+archive/ubuntu/kisak-mesa/+sourcefiles/mesa/24.0.3~kisak1~j/mesa_24.0.3~kisak1~j.tar.xz"

makedepends=("cmake" "pkg-config" "glslang-tools" "libwayland-egl-backend-dev" "flex" "llvm-15" "libxcb-glx0-dev" "libxcb-dri2-0-dev" "libxcb-dri3-dev" "libxcb-present-dev" "libxshmfence-dev" "libxfixes-dev" "libomxil-bellagio-dev" "libva-dev" "libvdpau-dev" "wayland-protocols" "libx11-xcb-dev" "libxxf86vm-dev" "directx-headers-dev" "libllvmspirvlib-15-dev" "spirv-tools" "libclang-dev" "clang" "libglvnd-dev" "valgrind" "libunwind-dev" "libsensors-dev" "python3-ply" "bindgen")

pacdeps=("libdrm" "meson")


#libegl-dev libgl-dev libglx-dev mesa-vulkan-driver libgl1 bindgen



provides=('libegl-mesa0' 'libgl1-mesa-dri' 'libglapi-mesa' 'libglu1-mesa' 'libglx-mesa0' 'libosmesa8' 'mesa-vulkan-drivers' 'mesa-vdpau-drivers' 'mesa-va-drivers' 'libxatracker2')

replaces=('libegl-mesa0' 'libgl1-mesa-dri' 'libglapi-mesa' 'libglu1-mesa' 'libglx-mesa0' 'libosmesa8' 'mesa-vulkan-drivers' 'mesa-vdpau-drivers' 'mesa-va-drivers' 'libxatracker2')


pkgdesc="free implementation of the OpenGL API -- GLX vendor library"
repology=("project: mesa")
arch=('amd64')
maintainer=("Cavern")

prepare() {
  cd "${_archive}"

echo "no patches"

}

build() {
  cd "${_archive}"

local meson_options=(
    -D android-libbacktrace=disabled
    -D b_ndebug=true
    -D dri3=enabled
    -D egl=enabled
    -D gbm=enabled
    -D gles1=disabled
    -D gles2=enabled
    -D glvnd=true
    -D glx=dri
    -D intel-clc=disabled
    -D libunwind=enabled
    -D llvm=enabled
    -D lmsensors=enabled
    -D microsoft-clc=disabled
    -D osmesa=true
    -D platforms=x11,wayland
    -D rust_std=2021
    -D shared-glapi=enabled
    -D valgrind=enabled
    -D video-codecs=all
    -D vulkan-drivers=amd,intel,intel_hasvk,swrast,virtio
    -D vulkan-layers=device-select,intel-nullhw,overlay
  )


  # Build only minimal debug info to reduce size
  CFLAGS+=' -g1'
  CXXFLAGS+=' -g1'

    arch-meson ./ build "${meson_options[@]}"
    meson configure build # Print config
    meson compile -C build

    # fake installation to be seperated into packages
    # outside of fakeroot but mesa doesn't need to chown/mod
    DESTDIR="${srcdir}/fakeinstall" meson install -C build
    ls ${srcdir}
    sleep 5

}

_install() {
  local src f dir
  for src; do
    f="${src#fakeinstall/}"
    dir="${pkgdir}/${f%/*}"
    sudo install -m755 -d "${dir}"
    sudo mv -v "${src}" "${dir}/"
  done
}

_libdir=usr/lib/x86_64-linux-gnu

package() {
  cd "${_archive}"

  set -e
  _libdir=usr/lib/x86_64-linux-gnu

# vulkan-mesa-layers

  _install fakeinstall/usr/share/vulkan/explicit_layer.d
  _install fakeinstall/usr/share/vulkan/implicit_layer.d
  _install fakeinstall/$_libdir/libVkLayer_*.so
  _install fakeinstall/usr/bin/mesa-overlay-control.py

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

# vulkan-intel

  _install fakeinstall/usr/share/vulkan/icd.d/intel_*.json
  _install fakeinstall/$_libdir/libvulkan_intel*.so

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE


# vulkan-radeon


  _install fakeinstall/usr/share/drirc.d/00-radv-defaults.conf
  _install fakeinstall/usr/share/vulkan/icd.d/radeon_icd*.json
  _install fakeinstall/$_libdir/libvulkan_radeon.so

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE


# vulkan-swrast

  _install fakeinstall/usr/share/vulkan/icd.d/lvp_icd*.json
  _install fakeinstall/$_libdir/libvulkan_lvp.so

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

# vulkan-virtio

  _install fakeinstall/usr/share/vulkan/icd.d/virtio_icd*.json
  _install fakeinstall/$_libdir/libvulkan_virtio.so

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

# libva-mesa-drivers

  _install fakeinstall/$_libdir/dri/*_drv_video.so

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

# mesa-vdpau

  _install fakeinstall/$_libdir/vdpau

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

# mesa

  _install fakeinstall/usr/share/drirc.d/00-mesa-defaults.conf
  _install fakeinstall/usr/share/glvnd/egl_vendor.d/50_mesa.json

  # ati-dri, nouveau-dri, intel-dri, svga-dri, swrast, swr
  _install fakeinstall/$_libdir/dri/*_dri.so

  _install fakeinstall/$_libdir/bellagio
  _install fakeinstall/$_libdir/d3d
  #_install fakeinstall/$_libdir/lib{gbm,glapi}.so*
  _install fakeinstall/$_libdir/libglapi.so*
  _install fakeinstall/$_libdir/libOSMesa.so*
  _install fakeinstall/$_libdir/libxatracker.so*

  _install fakeinstall/usr/include
  _install fakeinstall/$_libdir/pkgconfig

  # libglvnd support
  _install fakeinstall/$_libdir/libGLX_mesa.so*
  _install fakeinstall/$_libdir/libEGL_mesa.so*

  # indirect rendering
  ln -sr "$pkgdir"/$_libdir/libGLX_{mesa,indirect}.so.0

  # make sure there are no files left to install
  #find fakeinstall -depth -print0 | xargs -0 rmdir

  #install -m644 -Dt "${pkgdir}/usr/share/licenses/${gives}" LICENSE

}
