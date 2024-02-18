name="glffetch-git"
repology=("project: bar")
arch=('any' 'amd64' 'arm64')
pkgver="1.0"
pkgrel="1"


makedepends=("git")
pacdeps=("fastfetch" "nerd-fonts-hack")
gives="glffetch"
pkgdesc="Configuration for Fastfetch for the GLF Team Challenges"

url="https://github.com/Gaming-Linux-FR/GLFfetch.git"

maintainer="xdavius <xdavius@github.com>"

pkgver() {
git ls-remote "${url}" main | cut -f1 | cut -c1-8
}

prepare() {
chmod u+x scripts/*.sh
echo "install_name=${LOGNAME}" | tee glffetch.conf > /dev/null
echo "#!/bin/bash
fastfetch --config /home/${LOGNAME}/.config/fastfetch/GLFfetch/challenge.jsonc" | tee glffetch > /dev/null

}

package() {

source ./glffetch.conf

sudo install -Dm655 "glffetch.conf" "${pkgdir}/etc/glffetch.conf"

sudo install -d "${pkgdir}/home/${install_name}/.config/fastfetch/GLFfetch/scripts"
sudo install -Dm755 "glffetch" "${pkgdir}/usr/bin/glffetch"

sudo install -Dm655 "GLF.png" "${pkgdir}/home/${install_name}/.config/fastfetch/GLFfetch/GLF.png"
sudo install -Dm655 "challenge.jsonc" "${pkgdir}/home/${install_name}/.config/fastfetch/GLFfetch/challenge.jsonc"

sudo install -Dm755 scripts/*.sh -t "${pkgdir}/home/${install_name}/.config/fastfetch/GLFfetch/scripts"

}
