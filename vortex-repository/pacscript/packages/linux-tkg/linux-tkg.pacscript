name="linux-tkg"
arch=('any' 'amd64' 'arm64')
pkgver="$(curl --silent "https://api.github.com/repos/Frogging-Family/linux-tkg/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)"
pkgrel="1"

homepage='https://github.com/Frogging-Family/'
url="https://github.com/Frogging-Family/linux-tkg/archive/refs/tags/v{pkgver}.tar.gz"
makedepends=("build-essential" "patch" "ccache")

replace=("linux-image-${pkgver}tkg-eevdf" "linux-headers-${pkgver}tkg-eevdf")
gives="linux-tkg"
pkgdesc="Compile Linux-TKG kernel from source with your own configuration"

#hash="2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae"

maintainer="xdavius <xdavius@github.com>"

provides=('linux-image-tkg' 'linux-headers-tkg')

prepare() {
    patches_url="https://github.com/Xdavius/vortex-linux/tree/dev/vortex-repository/pacscript/packages/linux-tkg"
    wget ${patches_url}/customization.cfg

    read -p "Do you want to use your modprobed-db database ? [y/N]" modprobed_ask
    case ${modprobed_ask} in
    y|Y)
    echo '_modprobeddb="true"' > customization.cfg
    ;;
    n|N|*)
    echo '_modprobeddb="false"' > customization.cfg
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

