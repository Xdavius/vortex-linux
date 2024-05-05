pkgname="firefox-apt"
gives="firefox-apt"
pkgver="1.0"
source=(
  "https://github.com/Xdavius/VRAC/releases/download/empty/empty.tar.gz"
  "repo-signing-key.gpg::https://packages.mozilla.org/apt/repo-signing-key.gpg"
)
arch=("amd64")
pkgdesc="Mozilla Firefox APT repository"
maintainer=("Xdavius <xdavius@github.com>")

prepare() {
  cd "${_archive}"
  mv ${srcdir}/repo-signing-key.gpg packages.mozilla.org.asc

  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > mozilla.list

  echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' > mozilla
}

package() {
  cd "${_archive}"
  install -Dm644 packages.mozilla.org.asc "${pkgdir}/etc/apt/keyrings/packages.mozilla.org.asc"
  install -Dm644 mozilla.list "${pkgdir}/etc/apt/sources.list.d/mozilla.list"
  install -Dm644 mozilla "${pkgdir}/etc/preferences.d/mozilla"
}

post_install() {
  echo ""
  echo "Please do manualy apt update && apt upgrade or apt install firefox if necessary"
}

sha256sums=(
  "SKIP"
  "SKIP"
)
