# Debian Vortex Project
New Linux project based on Debian and Pacstall

For the moment, only the pacstall repository is available.

Clic [`HERE`](https://github.com/Xdavius/vortex-linux/tree/main/vortex-repository) for install instructions


## Nvidia Quick setup Guide


```
sudo apt autopurge *'nvidia'* libnvidia*
sudo apt install curl && sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
pacstall -A https://raw.githubusercontent.com/Xdavius/vortex-linux/main/vortex-repository/pacscript
pacstall -I nvidia-driver-production-dkms-bundle
```
