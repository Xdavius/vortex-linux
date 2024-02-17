name="amd-driver-full-repo"
gives="amd-driver-full-repo"
pkgdesc='Install all AMD APT repository'
pkgname="amd-driver-full-repo"
pkgver="23.40"
pkgrel="1"

depends=("gpg")

url="https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${pkgver}.tar.gz"
arch=("amd64")
license=('GPL2')


maintainer="xdavius <xdavius@github.com>"

hash="$(curl -sL ${url} | sha256sum | cut -d " " -f 1)"

prepare() {

# PATCHES

  patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/${name}"

  wget ${patches_url}/amdfw.gpg.key
  wget ${patches_url}/amdvlk.gpg.key
  wget ${patches_url}/rocm-keyring.gpg.key
  wget ${patches_url}/rocm.gpg.key

  wget ${patches_url}/rocm
  wget ${patches_url}/rocm.list

  cat amdfw.gpg.key | gpg --dearmor | tee mdfw.gpg > /dev/null
  cat amdvlk.gpg.key | gpg --dearmor | tee amdvlk.gpg > /dev/null
  cat rocm-keyring.gpg.key | gpg --dearmor | tee rocm-keyring.gpg > /dev/null
  cat rocm.gpg.key | gpg --dearmor | tee rocm.gpg > /dev/null
}

package() {

  sudo install -Dm 644 "amdfw.gpg" "${pkgdir}/usr/share/keyring/amdfw.gpg"
  sudo install -Dm 644 "amdvlk.gpg" "${pkgdir}/usr/share/keyring/amdvlk.gpg"
  sudo install -Dm 644 "rocm.gpg" "${pkgdir}/usr/share/keyring/rocm.gpg"
  sudo install -Dm 644 "rocm-keyring.gpg" "${pkgdir}/usr/share/keyring/rocm-keyring.gpg"

  sudo install -Dm 644 "rocm" "${pkgdir}/etc/apt/preferences.list.d/rocm"
  sudo install -Dm 644 "rocm.list" "${pkgdir}/etc/apt/sources.list.d/rocm.list"

}

post_install() {

usermod -aG video,render $(who | grep tty | cut -d " " -f 1)

echo "
Before installing packages, do : sudo apt update
"
echo "Install amdfwflash : sudo apt install amdfwflash"
echo "Install amdvlk : sudo apt install amdvlk"
echo "Install opencl : sudo apt install rocm-opencl-runtime"
echo "Install hip : sudo apt install rocm-hip-runtime"
}

