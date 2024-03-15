# Maintainer: Jan Alexander Steffens (heftig) <heftig@archlinux.org>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Contributor: Anatol Pomozov <anatol dot pomozov at gmail>
name="meson"
pkgname="meson"
pkgver="1.4.0"
pkgrel="2"
pkgdesc="High productivity build system"
url="https://mesonbuild.com/"
arch=("any")
license=("Apache")
gives="meson"

makedepends=(
  "python3-build"
  "python3-installer"
  "python3-setuptools"
  "python3-wheel"
  "ninja-build"
  "python3-tqdm"
  "python3-typing-extensions"
)

url="https://github.com/mesonbuild/meson/releases/download/${pkgver}/meson-${pkgver}.tar.gz"

prepare() {

  dl_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/meson/"

  wget https://github.com/mesonbuild/meson/releases/download/${pkgver}/meson-reference.3
  wget https://github.com/mesonbuild/meson/releases/download/${pkgver}/reference_manual.json

  wget ${dl_url}arch-meson
  wget ${dl_url}cross-lib32
  wget ${dl_url}native-clang
  wget ${dl_url}0001-Skip-broken-tests.patch
  wget ${dl_url}0002-unittests-Add-a-helper-for-copying-source-trees.patch
  wget ${dl_url}0003-tests-Fix-unit-tests-with-high-parallelism.patch
  wget ${dl_url}0004-Revert-rust-recursively-pull-proc-macro-dependencies.patch

  # Pass tests
  patch -Np1 -i 0001-Skip-broken-tests.patch

  # https://github.com/mesonbuild/meson/pull/12937
  patch -Np1 -i 0002-unittests-Add-a-helper-for-copying-source-trees.patch
  patch -Np1 -i 0003-tests-Fix-unit-tests-with-high-parallelism.patch

  # Fix lib32-mesa
  patch -Np1 -i 0004-Revert-rust-recursively-pull-proc-macro-dependencies.patch
}

build() {
  python3 -m build --wheel --no-isolation
}

check() (
  export LC_CTYPE=en_US.UTF-8 CPPFLAGS= CFLAGS= CXXFLAGS= LDFLAGS=
  ./run_tests.py --failfast
)

package() {
  sudo python3 -m installer --destdir="${pkgdir}" dist/*.whl

  sudo install -d "${pkgdir}/usr/share/vim/vimfiles"
  sudo cp -rt "${pkgdir}/usr/share/vim/vimfiles" data/syntax-highlighting/vim/*/

  sudo install -Dm644 data/shell-completions/bash/* -t "${pkgdir}/usr/share/bash-completion/completions"
  sudo install -Dm644 data/shell-completions/zsh/*  -t "${pkgdir}/usr/share/zsh/site-functions"

  sudo install -Dm644 meson-reference.3     "${pkgdir}/usr/share/man/man3/meson-reference.3"
  sudo install -Dm644 reference_manual.json "${pkgdir}/usr/share/doc/$pkgname/reference_manual.json"

  sudo install -D arch-meson -t "${pkgdir}/usr/bin"

  sudo install -Dm644 cross-lib32 "${pkgdir}/usr/share/meson/cross/lib32"
  sudo install -Dm644 native-clang "${pkgdir}/usr/share/meson/native/clang"
}

