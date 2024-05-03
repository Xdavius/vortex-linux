pkgname="discord-autoupdated-deb"
gives="discord-autoupdated-deb"
breaks=("${gives}" "${gives}-app" "${gives}-debian-patched-deb")

version_url="https://gitlab.archlinux.org/archlinux/packaging/packages/discord/-/raw/main/PKGBUILD"
pkgver="$(curl -sL $version_url | grep pkgver= | cut -d "=" -f 2)"

pkgdesc="Download and install latest Discord version"

maintainer=("ObsidianPresidium <emil@aarestrup.nu>")
arch=('amd64')
source=("https://discordapp.com/api/download?platform=linux&format=deb")

sha256sums=("$(curl -sL $url | sha256sum | cut -d " " -f 1)")

homepage='https://discord.com/'
repology=("project: ${gives}")

prepare() {
  cd "${_archive}"
mv "download?platform=linux&format=deb" "discord.deb"
apt install -y ./discord.deb
}
