pkgname="fastfetch"
gives="fastfetch"
pkgdesc="Like neofetch, but much faster because written in c"
pkgver="2.11.3"
pkgrel="1"
breaks=("${gives}" "${gives}-bin" "${gives}-deb" "${gives}-app" "${gives}-git")
url="https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/${pkgver}.tar.gz"
source=("https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/${pkgver}.tar.gz")
maintainer=("xdavius <xdavius@github.com>")

makedepends=("cmake" "libpci-dev" "libvulkan-dev" "libwayland-dev" "libxrandr-dev" "libxcb-randr0-dev"
            "libdconf-dev" "libmagick++-dev" "libmagickcore-dev" "libdbus-1-dev" "libpci-dev" "libxfconf-0-dev"
            "libegl-dev" "libglx-dev" "libosmesa6-dev" "ocl-icd-opencl-dev" "libnm-dev" "libpulse-dev" "libddcutil-dev" "directx-headers-dev" "libchafa-dev")

optdepends=("libvulkan1: Vulkan module and GPU fallback"
  "libegl-dev: OpenGL module"
  "libxcb1-dev: Resolution and refresh rate support for X11 sessions"
  "libwayland-dev: Resolution and refresh rate support for wayland sessions"
  "libglib2.0-dev: Output for values that are only stored in GSettings"
  "libdconf-dev: Output for values that are only stored in DConf"
  "libxfconf-0-dev: XFWM theme + xfce-terminal font"
  "libnm-dev: Used for Wifi detection"
  "libpulse-dev: Used for Sound device detection"
  "libddcutil-dev: Used for brightness detection for external displays"
  "libdbus-1-dev: Used for bluetooth, Player & Media detection"
  "kitty: Terminal emulator GPU accelerated and display images"
  "chafa: Show images in non OpenGL Terminal"
)

build() {
  cd "${_archive}"
  
  mkdir -p build/
  (
    cd build/ || return 2
    cmake ..
    cmake --build . --target fastfetch --target flashfetch -j "${NCPU}"
  )
}

package() {
  cd "${_archive}"
  # Install license
  install -Dm644 "LICENSE" -t "${pkgdir}/usr/share/licenses/${gives}"

  # Install doc
  install -Dm644 "README.md" -t "${pkgdir}/usr/share/doc/${gives}"

  # Install fastfetch and flashfetch binary
  install -Dm755 "build/fastfetch" "build/flashfetch" -t "${pkgdir}/usr/bin"

  # Install bash completions
  install -Dm644 "completions/bash" "${pkgdir}/usr/share/bash-completion/completions/${gives}"

  # Install presets
  mkdir -p "${pkgdir}/usr/share/${gives}/presets"
  cp -r presets/* "${pkgdir}/usr/share/${gives}/presets"
}

post_remove() {
  # Remove empty directories
  rm -rf "/usr/share/licenses/${gives}"
  rm -rf "/usr/share/doc/${gives}"
  rm -rf "/usr/share/${gives}"
}

