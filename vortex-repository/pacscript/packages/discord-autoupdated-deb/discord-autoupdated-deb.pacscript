name="discord-autoupdated-deb"
gives="discord-autoupdated-deb"
breaks=("${gives}" "${gives}-app" "${gives}-debian-patched-deb")

version_url="https://gitlab.archlinux.org/archlinux/packaging/packages/discord/-/raw/main/PKGBUILD"
pkgver="$(curl -sL $version_url | grep pkgver= | cut -d "=" -f 2)"

pkgdesc="Download and install latest Discord version"

maintainer="ObsidianPresidium <emil@aarestrup.nu>"
arch=('amd64')
url="https://discordapp.com/api/download?platform=linux&format=deb"

hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

homepage='https://discord.com/'
repology=("project: ${gives}")

prepare() {
mv "download?platform=linux&format=deb" "discord.deb"
sudo apt install -y ./discord.deb
}
