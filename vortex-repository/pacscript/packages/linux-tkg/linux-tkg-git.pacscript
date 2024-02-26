name="linux-tkg-git"
arch=('any' 'amd64' 'arm64')
pkgver="$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)"
pkgrel="1"

makedepends=("build-essential" "patch" "ccache" 'bc' 'bison' 'cpio' 'fakeroot' 'flex' 'git' 'kmod' 'libelf-dev' 'libncurses5-dev' 'libssl-dev' 'lz4' 'qtbase5-dev' 'rsync' 'schedtool' 'wget' 'zstd' 'debhelper')
replace=("linux-image-${pkgver}tkg-eevdf" "linux-headers-${pkgver}tkg-eevdf")
gives="linux-tkg"
provides=('linux-image-tkg' 'linux-headers-tkg')
pkgdesc="Compile Linux-TKG kernel from source with your own configuration"

homepage='https://github.com/Frogging-Family/'
url="https://github.com/Frogging-Family/linux-tkg.git"

maintainer="xdavius <xdavius@github.com>"

prepare() {
    rm customization.cfg
    patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/linux-tkg"
    wget ${patches_url}/customization.cfg

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

package() {

    sudo cp -R . /usr/src/linux-tkg-${pkgver}-vortex
    cd /usr/src/linux-tkg-${pkgver}-vortex
    sudo make modules_install
    sudo make install
}

post_install() {
  update-initramfs -u -k all
  update-grub
}

post_remove() {

  update-grub
}

