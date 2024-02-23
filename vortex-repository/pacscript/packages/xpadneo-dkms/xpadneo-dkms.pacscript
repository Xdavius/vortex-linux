# Mantainer: marmis <tiagodepalves@gmail.com>
# Contributor: vitor_hideyoshi <vitor.h.n.batista@gmail.com>
# Contributor: katt <magunasu.b97@gmail.com>
# Contributor: Yangtse Su <i@yangtse.me>
name="xpadneo-dkms"
_pkgname=xpadneo
_dkmsname=hid-${_pkgname}
pkgname=${_pkgname}-dkms
pkgver=0.9.6
_pkgver=v${pkgver}
pkgrel=1
pkgdesc="Advanced Linux Driver for Xbox One S/X Wireless Gamepad"
arch=('any')
homepage='https://github.com/atar-axis/xpadneo'
license=('GPL3')
depends=('dkms' 'bluetooth' 'linux-headers-amd64')
url=("${homepage}/archive/${_pkgver}.tar.gz")


prepare() {

    # PATCHES

    patches_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/xpadneo-dkms"

    wget ${patches_url}/drop-etc-files.patch
    wget ${patches_url}/rename-marker.patch
    wget ${patches_url}/prerm-xpadneo

    cd "${_dkmsname}"

    # Upstream uses dkms.post_install to create modprobe and udev files in
    # /etc. In Arch, it makes more sense to create these files in /usr/lib
    # and let pacman take care of them.
    patch -p1 -i "../drop-etc-files.patch"

    # Set the current version in DKMS config file.
    patch -p1 -i "../rename-marker.patch"
    sed "s/@PACKAGE_VERSION@/${_pkgver}/" dkms.conf.in > dkms.conf
}

check() {
    # Warning if missing linux-headers for current `uname -r` kernel
    if [ ! -f "/usr/lib/modules/$(uname -r)/build/Makefile" ]
    then
        _BOLDRED='\033[1;31m'
        _RED='\033[0;31m'
        _RESET='\033[0m'
        echo -e "${_BOLDRED}WARNING:${_RED} You may be missing headers for your current kernel, DKMS packages requires them."
        echo -e "Please refer to https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support for details.${_RESET}"
    fi
}

package() {
    cd "${srcdir}/${_dkmsname}"

    # Module source
    sudo install -Dm0644 -t "${pkgdir}/usr/src/${_dkmsname}-${_pkgver}/src" src/*

    # DKMS files
    sudo install -Dm0644 -t "${pkgdir}/usr/src/${_dkmsname}-${_pkgver}" Makefile dkms.conf dkms.post_install dkms.post_remove
    sudo install -Dm0755 -t "${pkgdir}/usr/src/${_dkmsname}-${_pkgver}" dkms.post_install dkms.post_remove

    # modprobe aliases
    sudo install -Dm0644 -t "${pkgdir}/usr/lib/modprobe.d" etc-modprobe.d/*

    # udev rules
    sudo install -Dm0644 -t "${pkgdir}/usr/lib/udev/rules.d" etc-udev-rules.d/*

# FIX : BECAUSE PACSTALL DOESN'T HAVE PRE_REMOVE() FUNCTION
# CREATE PRERM DEBIAN SCRIPT

sudo mkdir -p "${pkgdir}/DEBIAN/"
sudo mv ${srcdir}/prerm-xpadneo ${pkgdir}/DEBIAN/prerm
sudo chmod +x ${pkgdir}/DEBIAN/prerm

}

post_install() {

set -e

DKMS_NAME=hid-xpadneo
DKMS_VERSION=v0.9.6

dkms add -m ${DKMS_NAME} -v ${DKMS_VERSION}
dkms build -m ${DKMS_NAME} -v ${DKMS_VERSION} && dkms install -m ${DKMS_NAME} -v ${DKMS_VERSION} --force || true

post_upgrade

}
