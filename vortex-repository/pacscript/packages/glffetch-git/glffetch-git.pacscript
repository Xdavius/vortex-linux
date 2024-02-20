name="glffetch-git"

arch=('any')
pkgver="1.0"
pkgrel="1"

gives="glffetch"
makedepends=("git")
pacdeps=("fastfetch" "nerd-fonts-hack")
pkgdesc="Configuration for Fastfetch for the GLF Team Challenges"

url="https://github.com/Gaming-Linux-FR/GLFfetch.git"

maintainer="xdavius <xdavius@github.com>"

pkgver() {
git ls-remote "${url}" main | cut -f1 | cut -c1-8
}

prepare() {
chmod u+x scripts/*.sh
echo "#!/bin/bash
source /home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts/icon.sh
fastfetch --config /home/${LOGNAME}/.config/fastfetch/GLFfetch/challenge.jsonc" | tee glffetch > /dev/null

}

package() {

sudo install -Dm755 "glffetch" "${pkgdir}/usr/bin/glffetch"

sudo install -d "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts"

sudo install -Dm655 "GLF.png" "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/GLF.png"
sudo install -Dm655 "challenge.jsonc" "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/challenge.jsonc"

sudo install -Dm755 scripts/*.sh -t "${pkgdir}/home/${LOGNAME}/.config/fastfetch/GLFfetch/scripts"

sudo chown -R ${LOGNAME}:${LOGNAME} ${pkgdir}/home/${LOGNAME}/.config/fastfetch
}
