name="fastfetch"
pkgname="fastfetch"
pkgdesc="Like neofetch, but much faster because written in c"

pkgver=$(curl --silent "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')

makedepends=("cmake" "libpci-dev" "libvulkan-dev" "libwayland-dev" "libxrandr-dev" "libxcb-randr0-dev"
            "libdconf-dev" "libmagick++-dev" "libmagickcore-dev" "libdbus-1-dev" "libpci-dev" "libxfconf-0-dev"
            "libegl-dev" "libglx-dev" "libosmesa6-dev" "ocl-icd-opencl-dev" "libnm-dev" "libpulse-dev" "libddcutil-dev" "directx-headers-dev" "libchafa-dev")

optdepends=("libvulkan1: Vulkan module and GPU fallback"
  "libegl-dev: OpenGL module"
  "libxcb-dev: Resolution and refresh rate support for X11 sessions"
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

breaks=("${pkgname}" "${pkgname}-bin" "${pkgname}-deb" "${pkgname}-app" "${pkgname}-git")

url="https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/${pkgver}.tar.gz"
hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

maintainer="xdavius <xdavius@github.com>"

build() {
  
  mkdir -p build/
  (
    cd build/ || return 2
    cmake ..
    cmake --build . --target fastfetch --target flashfetch -j "${NCPU}"
  )
}

package() {
  # Install license
  sudo install -Dm644 "LICENSE" -t "${pkgdir}/usr/share/licenses/${pkgname}"

  # Install doc
  sudo install -Dm644 "README.md" -t "${pkgdir}/usr/share/doc/${pkgname}"

  # Install fastfetch and flashfetch binary
  sudo install -Dm755 "build/fastfetch" "build/flashfetch" -t "${pkgdir}/usr/bin"

  # Install bash completions
  sudo install -Dm644 "completions/bash" "${pkgdir}/usr/share/bash-completion/completions/${pkgname}"

  # Install presets
  sudo mkdir -p "${pkgdir}/usr/share/${pkgname}/presets"
  sudo cp -r presets/* "${pkgdir}/usr/share/${pkgname}/presets"
}

post_remove() {
  # Remove empty directories
  sudo rm -rf "/usr/share/licenses/${pkgname}"
  sudo rm -rf "/usr/share/doc/${pkgname}"
  sudo rm -rf "/usr/share/${pkgname}"
}

