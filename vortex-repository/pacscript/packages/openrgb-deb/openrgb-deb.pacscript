#from gitlab release page

pkgname="openrgb-deb"
gives="openrgb"
arch=('amd64')
pkgver="0.9"
pkgrel="1"
_commit="b5f46e3"
breaks=("${gives}-git")

pkgdesc="Control all of your RGB devices from a single app,"

homepage='https://openrgb.org/releases/'
source=("${url}/release_${pkgver}/${gives}_${pkgver}_${arch}_bookworm_${_commit}.deb")

sha256sums=("$(curl -sL $url | sha256sum | cut -d " " -f 1)")

maintainer=("xdavius <xdavius@github.com>")

incompatible=('ubuntu:*')
