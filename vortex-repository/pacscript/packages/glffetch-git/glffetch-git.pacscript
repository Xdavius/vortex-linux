pkgname="glffetch-git"
gives="glffetch-git"
arch=('any')
pkgver="1.0"
pkgrel="1"
makedepends=("git")
pacdeps=("fastfetch" "nerd-fonts-hack")
pkgdesc="Configuration for Fastfetch for the GLF Team Challenges"

source=("https://github.com/Xdavius/GLFfetch.git")

maintainer=("xdavius <xdavius@github.com>")


prepare() {
  cd "${_archive}"
chmod u+x scripts/*.sh
echo "#!/bin/bash
source /home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts/icon.sh
fastfetch --config /home/${LOGNAME}/.config/fastfetch/GLFfetch/challenge.jsonc" | tee glffetch > /dev/null

}

package() {
  cd "${_archive}"

install -Dm755 "glffetch" "${pkgdir}/usr/bin/glffetch"
install -d "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts"
install -Dm655 "GLF.png" "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/GLF.png"
install -Dm655 "challenge.jsonc" "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/challenge.jsonc"
install -Dm755 scripts/*.sh -t "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts"
chown -R ${LOGNAME}:${LOGNAME} ${pkgdir}/home/${LOGNAME}/.config/fastfetch
}

post_install() {

echo '
IN CASE OF ERROR "PERMISSION DENIED", DELETE $HOME/.config/fastfetch/GLFfetch FOLDER AND REINSTALL THE PACKAGE
'
}
