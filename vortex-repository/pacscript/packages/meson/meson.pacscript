# Maintainer: Jan Alexander Steffens (heftig) <heftig@archlinux.org>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Contributor: Anatol Pomozov <anatol dot pomozov at gmail>
pkgname="meson"
gives="meson"
pkgver="1.4.0"
pkgrel="2"
pkgdesc="High productivity build system"
source=("https://mesonbuild.com/")
arch=("any")
license=("Apache")

makedepends=(
  "python3-build"
  "python3-installer"
  "python3-setuptools"
  "python3-wheel"
  "ninja-build"
  "python3-tqdm"
  "python3-typing-extensions"
)

source=("https://github.com/mesonbuild/meson/releases/download/${pkgver}/meson-${pkgver}.tar.gz")

prepare() {
  cd "${_archive}"

  dl_url="https://raw.githubusercontent.com/Xdavius/vortex-linux/dev/vortex-repository/pacscript/packages/meson/"



  # Pass tests
  patch -Np1 -i 0001-Skip-broken-tests.patch

  # https://github.com/mesonbuild/meson/pull/12937
  patch -Np1 -i 0002-unittests-Add-a-helper-for-copying-source-trees.patch
  patch -Np1 -i 0003-tests-Fix-unit-tests-with-high-parallelism.patch

  # Fix lib32-mesa
  patch -Np1 -i 0004-Revert-rust-recursively-pull-proc-macro-dependencies.patch
}

build() {
  cd "${_archive}"
  python3 -m build --wheel --no-isolation
}

check() (
  export LC_CTYPE=en_US.UTF-8 CPPFLAGS= CFLAGS= CXXFLAGS= LDFLAGS=
  ./run_tests.py --failfast
)

package() {
  cd "${_archive}"
  python3 -m installer --destdir="${pkgdir}" dist/*.whl

  install -d "${pkgdir}/usr/share/vim/vimfiles"
  cp -rt "${pkgdir}/usr/share/vim/vimfiles" data/syntax-highlighting/vim/*/

  install -Dm644 data/shell-completions/bash/* -t "${pkgdir}/usr/share/bash-completion/completions"
  install -Dm644 data/shell-completions/zsh/*  -t "${pkgdir}/usr/share/zsh/site-functions"

  install -Dm644 ${srcdir}/meson-reference.3     "${pkgdir}/usr/share/man/man3/meson-reference.3"
  install -Dm644 ${srcdir}/reference_manual.json "${pkgdir}/usr/share/doc/$gives/reference_manual.json"

  install -D arch-meson -t "${pkgdir}/usr/bin"

  install -Dm644 cross-lib32 "${pkgdir}/usr/share/meson/cross/lib32"
  install -Dm644 native-clang "${pkgdir}/usr/share/meson/native/clang"
}


sha256sums=(
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
  "SKIP"
)
