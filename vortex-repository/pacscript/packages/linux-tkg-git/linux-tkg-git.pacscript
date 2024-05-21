pkgname="linux-tkg-git"
arch=('any')
pkgver="8.0"
pkgrel="1"

makedepends=("build-essential" "patch" "ccache" 'bc' 'bison' 'cpio' 'fakeroot' 'flex' 'git' 'kmod' 'libelf-dev' 'libncurses5-dev' 'libssl-dev' 'lz4' 'qtbase5-dev' 'rsync' 'schedtool' 'wget' 'zstd' 'debhelper')
replaces=("linux-image-${pkgver}tkg-eevdf" "linux-headers-${pkgver}tkg-eevdf")
gives="linux-tkg"
provides=('linux-image-tkg' 'linux-headers-tkg')
pkgdesc="Compile Linux-TKG kernel from source with your own configuration"

homepage='https://github.com/Frogging-Family/'
source=("https://github.com/Frogging-Family/linux-tkg.git")

maintainer=("xdavius <xdavius@github.com>")


prepare() {
  cd "${_archive}"

    rm customization.cfg
    rm install.sh

    patches_url="git+https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/linux-tkg-git"
    wget ${patches_url}/customization.cfg
    wget ${patches_url}/install.sh.new

    mv install.sh.new install.sh
    chmod +x install.sh

    read -p "Do you want to use your modprobed-db database ? [y/N]" modprobed_ask
    case ${modprobed_ask} in
    y|Y)
    echo '_modprobeddb="true"' >> customization.cfg
    ;;
    n|N|*)
    echo '_modprobeddb="false"' >> customization.cfg
    ;;
    esac

    ./install.sh install
}

post_install() {
  update-initramfs -c -k all
  update-grub
}

post_remove() {
  rm /boot/initrd.img-*-vortex
  update-grub
}

