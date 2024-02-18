name="amdgpu-install-deb"
arch=('amd64')
pkgver="6.0.60000"
pkgrel="1"

url="https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_${pkgver}-${pkgrel}_all.deb"

gives="amdgpu-install"
pkgdesc="AMDGPU Official Installer from Radeon Repository"

hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

maintainer="xdavius <xdavius@github.com>"

prepare() {

sudo usermod -aG video,render $LOGNAME
}

post_install() {

echo "deb https://repo.radeon.com/amdgpu/latest/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/amdgpu.list > /dev/null
echo "deb [arch=amd64] https://repo.radeon.com/rocm/apt/latest jammy main" | sudo tee /etc/apt/sources.list.d/rocm.list > /dev/null

echo "
-------------------------------------------------------------------------------------
"
echo "
You need to REBOOT for group add take effect.

BEFORE INSTALLING SOMETHING, DO : sudo apt upgrade
"
echo "UPGRADE FIRMWARE : sudo apt install amdgpu-dkms-firmware"
echo "INSTALL ROCM OPENCL : sudo apt install rocm-opencl-runtime"
echo "INSTALL ROCM HIP : sudo apt install rocm-hip-runtime"

}
