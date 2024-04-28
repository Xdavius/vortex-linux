name="firefox-apt"
gives="firefox-apt"
pkgver="1.0"
url="https://github.com/Xdavius/VRAC/releases/download/empty/empty.tar.gz"
arch=("amd64")
pkgdesc="Mozilla Firefox APT repository"
maintainer="Xdavius <xdavius@github.com>"

prepare() {
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg
  mv repo-signing-key.gpg packages.mozilla.org.asc

  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > mozilla.list

  echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' > mozilla
}

package() {
  sudo install -Dm644 packages.mozilla.org.asc "${pkgdir}/etc/apt/keyrings/packages.mozilla.org.asc"
  sudo install -Dm644 mozilla.list "${pkgdir}/etc/apt/sources.list.d/mozilla.list"
  sudo install -Dm644 mozilla "${pkgdir}/etc/preferences.d/mozilla"
}

post_install() {
  echo ""
  echo "Please do manualy apt update && apt upgrade or apt install firefox if necessary"
}
