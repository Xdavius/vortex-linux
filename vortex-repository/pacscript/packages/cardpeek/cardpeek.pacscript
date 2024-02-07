name=cardpeek
pkgname=cardpeek
pkgver=0.8.4
pkgrel=3
pkgdesc="A tool to read-only the contents of smartcards"
gives="${pkgname}"
replace=("${pkgname}" "${pkgname}-data")
arch=('amd64')
url="http://downloads.pannetrat.com/install/${pkgname}-${pkgver}.tar.gz"
license='GPL3'
makedepends=('libgtk-3-dev' 'liblua5.2-dev' 'libpcsclite-dev' 'libcurlpp-dev' 'libssl-dev')
depends=('libgtk-3-dev' 'liblua5.2-0' 'libpcsclite-dev' 'curl')
sha256sums=('9c78dfdf84493c551b49447e4bb46c8d7b33f0785b93893222b70b6115013a85')

build() {
  cd ${pkgname}-${pkgver}
  ./configure LUA_CFLAGS="-I/usr/include/lua5.2" LUA_LIBS="-llua5.2 -lm" --prefix=/usr
  make
}

package() {
  cd ${pkgname}-${pkgver}
  sudo make DESTDIR="${pkgdir}" install
}
