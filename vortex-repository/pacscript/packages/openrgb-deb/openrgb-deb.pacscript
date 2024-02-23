#from gitlab release page

name="openrgb-deb"
pkgname="openrgb"
arch=('amd64')
pkgver="0.9"
pkgrel="1"
_commit="b5f46e3"
gives="openrgb"
breaks=("${pkgname}-git")

pkgdesc="Control all of your RGB devices from a single app,"

homepage='https://openrgb.org/releases/'
url="${homepage}/release_${pkgver}/${pkgname}_${pkgver}_${arch}_bookworm_${_commit}.deb"

hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

maintainer="xdavius <xdavius@github.com>"

incompatible=('ubuntu:*')
