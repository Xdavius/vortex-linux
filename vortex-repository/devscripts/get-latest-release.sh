get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Usage
# $ get_latest_release "creationix/nvm"
# v0.31.4
repolist="
  Frogging-Family/linux-tkg
  "

for str in ${repolist[@]}; do
  echo $str
  get_latest_release $str
done
