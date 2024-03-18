name="lib32-mesa"
gives="lib32-mesa"
pkgname="lib32-mesa"
pkgver="24.0.2"
pkgrel=1
url="https://mesa.freedesktop.org/archive/mesa-${pkgver}.tar.xz"

makedepends=("cmake" "pkg-config" "glslang-tools" "libwayland-egl-backend-dev" "flex" "llvm" "libxcb-glx0-dev:i386" "libxcb-dri2-0-dev" "libxcb-dri3-dev" "libxcb-present-dev:i386" "libxshmfence-dev:i386" "libomxil-bellagio-dev:i386" "libva-dev:i386" "libvdpau-dev:i386" "libllvm16:i386" "libclang-16-dev" "wayland-protocols" "crossbuild-essential-i386" "libc6-dev-i386")

pacdeps=("libdrm" "meson")

#replace=('libd3dadapter9-mesa' 'libd3dadapter9-mesa-dev' 'libegl-mesa0' 'libegl1-mesa' 'libegl1-mesa-dev' 'libgbm-dev' 'libgbm1' 'libgl1-mesa-dev' 'libgl1-mesa-dri' 'libgl1-mesa-glx' 'libglapi-mesa' 'libgles2-mesa' 'libgles2-mesa-dev' 'libglx-mesa0' 'libosmesa6' 'libosmesa6-dev' 'libwayland-egl1-mesa' 'libxatracker-dev' 'libxatracker2' 'mesa-common-dev' 'mesa-drm-shim' 'mesa-opencl-icd' 'mesa-va-drivers' 'mesa-vdpau-drivers' 'mesa-vulkan-drivers')

#provides=('libd3dadapter9-mesa' 'libd3dadapter9-mesa-dev' 'libegl-mesa0' 'libegl1-mesa' 'libegl1-mesa-dev' 'libgbm-dev' 'libgbm1' 'libgl1-mesa-dev' 'libgl1-mesa-dri' 'libgl1-mesa-glx' 'libglapi-mesa' 'libgles2-mesa' 'libgles2-mesa-dev' 'libglx-mesa0' 'libosmesa6' 'libosmesa6-dev' 'libwayland-egl1-mesa' 'libxatracker-dev' 'libxatracker2' 'mesa-common-dev' 'mesa-drm-shim' 'mesa-opencl-icd' 'mesa-va-drivers' 'mesa-vdpau-drivers' 'mesa-vulkan-drivers')

pkgdesc="free implementation of the OpenGL API -- GLX vendor library"
repology=("project: mesa")
arch=('i386')
maintainer="Cavern"

prepare() {

echo "no patches"

}

build() {
    local meson_options_lib32=(
    --cross-file lib32
    -D android-libbacktrace=disabled
    -D b_ndebug=true
    -D dri3=enabled
    -D egl=enabled
    -D gallium-drivers=r300,r600,radeonsi,nouveau,virgl,svga,swrast,i915,iris,crocus,zink
    -D gallium-extra-hud=true
    -D gallium-nine=true
    -D gallium-omx=disabled
    -D gallium-opencl=icd
    -D gallium-rusticl=true
    -D gallium-va=enabled
    -D gallium-vdpau=enabled
    -D gallium-xa=enabled
    -D gbm=enabled
    -D gles1=disabled
    -D gles2=enabled
    -D glvnd=true
    -D glx=dri
    -D intel-clc=enabled
    -D libunwind=enabled
    -D llvm=enabled
    -D lmsensors=enabled
    -D microsoft-clc=disabled
    -D osmesa=true
    -D platforms=x11,wayland
    -D rust_std=2021
    -D shared-glapi=enabled
    -D valgrind=disabled
    -D video-codecs=all
    -D vulkan-drivers=amd,intel,intel_hasvk,swrast,virtio
    -D vulkan-layers=device-select,intel-nullhw,overlay
  )


    CFLAGS+=' -g1'
    CXXFLAGS+=' -g1'

    export BINDGEN_EXTRA_CLANG_ARGS="-m32"
    export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig:/usr/share/pkgconfig \
    export PKG_CONFIG_LIBDIR=/usr/lib/i386-linux-gnu \
    export PKG_CONFIG_SYSROOT_DIR=/ \

    arch-meson ./ build "${meson_options[@]}"
    meson configure build # Print config
    meson compile -C build

    # fake installation to be seperated into packages
    # outside of fakeroot but mesa doesn't need to chown/mod
    DESTDIR="${srcdir}/fakeinstall" meson install -C build

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

_libdir=usr/i386-linux-gnu

package() {

# lib32-vulkan-mesa-layers
  sudo rm -rv fakeinstall/usr/share/vulkan/explicit_layer.d
  sudo rm -rv fakeinstall/usr/share/vulkan/implicit_layer.d
  _install fakeinstall/$_libdir/libVkLayer_*.so
  sudo rm -v fakeinstall/usr/bin/mesa-overlay-control.py

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-vulkan-intel

  _install fakeinstall/usr/share/vulkan/icd.d/intel_*.json
  _install fakeinstall/$_libdir/libvulkan_intel*.so

# lib32-vulkan-radeon

  sudo rm -v fakeinstall/usr/share/drirc.d/00-radv-defaults.conf
  _install fakeinstall/usr/share/vulkan/icd.d/radeon_icd*.json
  _install fakeinstall/$_libdir/libvulkan_radeon.so

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-vulkan-swrast

  _install fakeinstall/usr/share/vulkan/icd.d/lvp_icd*.json
  _install fakeinstall/$_libdir/libvulkan_lvp.so

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-vulkan-virtio

  _install fakeinstall/usr/share/vulkan/icd.d/virtio_icd*.json
  _install fakeinstall/$_libdir/libvulkan_virtio.so

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-libva-mesa-drivers

  _install fakeinstall/$_libdir/dri/*_drv_video.so

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-mesa-vdpau

  _install fakeinstall/$_libdir/vdpau

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

# lib32-mesa

  sudo rm -v fakeinstall/usr/share/drirc.d/00-mesa-defaults.conf
  sudo rm -v fakeinstall/usr/share/glvnd/egl_vendor.d/50_mesa.json

  # ati-dri, nouveau-dri, intel-dri, svga-dri, swrast, swr
  _install fakeinstall/$_libdir/dri/*_dri.so

  _install fakeinstall/$_libdir/d3d
  _install fakeinstall/$_libdir/lib{gbm,glapi}.so*
  _install fakeinstall/$_libdir/libOSMesa.so*
  _install fakeinstall/$_libdir/libxatracker.so*

  sudo rm -rv fakeinstall/usr/include
  _install fakeinstall/$_libdir/pkgconfig

  # libglvnd support
  _install fakeinstall/$_libdir/libGLX_mesa.so*
  _install fakeinstall/$_libdir/libEGL_mesa.so*

  # indirect rendering
  sudo ln -sr "$pkgdir"/$_libdir/libGLX_{mesa,indirect}.so.0

  # make sure there are no files left to install
  sudo find fakeinstall -depth -print0 | xargs -0 rmdir

  sudo install -m644 -Dt "${pkgdir}/usr/share/licenses/${pkgname}" LICENSE

}
