name="discord-autoupdated-deb"
gives="discord"
breaks=("${gives}" "${gives}-app" "${gives}-debian-patched-deb")

version_url="https://gitlab.archlinux.org/archlinux/packaging/packages/discord/-/raw/main/PKGBUILD"
pkgver="$(curl -sL $version_url | grep pkgver= | cut -d "=" -f 2)"

pkgdesc="Chat for Communities and Friends. Discord is the easiest way to communicate over voice, video, and text. Chat, hang out, and stay close with your friends and communities"

maintainer="ObsidianPresidium <emil@aarestrup.nu>"
arch=('amd64')
url="https://discordapp.com/api/download?platform=linux&format=deb"

hash="$(curl -sL $url | sha256sum | cut -d " " -f 1)"

homepage='https://discord.com/'
repology=("project: ${gives}")
