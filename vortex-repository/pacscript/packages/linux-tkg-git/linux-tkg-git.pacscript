name="linux-tkg-git"
arch=('any')
pkgver="8.0"
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
    rm install.sh

    patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/linux-tkg-git"
    wget ${patches_url}/customization.cfg
    wget ${patches_url}/install.sh.new

    mv install.sh.new install.sh

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
  update-initramfs -u -k all
  update-grub
}

post_remove() {

  update-grub
}

