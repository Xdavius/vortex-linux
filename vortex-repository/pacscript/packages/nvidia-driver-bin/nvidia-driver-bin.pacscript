name="nvidia-driver-bin"
pkgbase="nvidia-utils"
pkgname=('lib-nvidia-utils')
pkgver="545.29.06"
pkgrel="1"
pkgdesc="Nvidia Production Driver + lib32"
gives="${name}"
arch=('amd64')
license=('custom')
options=('!strip')
makedepends=("patchelf") 
depends=("wget" "dkms" "linux-headers-amd64" "libglvnd-dev" "libnvidia-egl-wayland-dev" "zlib1g-dev" "zlib1g-dev:i386" "libglvnd-dev:i386" "libgcc-12-dev:i386")
breaks=("nvidia-driver" "nvidia-driver-libs:i386" "nvidia-cuda-dev" "nvidia-cuda-toolkit")
_pkg="NVIDIA-Linux-x86_64-${pkgver}"
url="https://us.download.nvidia.com/XFree86/Linux-x86_64/${pkgver}/${_pkg}.run"
maintainer="xdavius <xdavius@github.com>"

create_links() {
    # create soname links
    find "$pkgdir" -type f -name '*.so*' ! -path '*xorg/*' -print0 | while read -d $'\0' _lib; do
        _soname=$(dirname "${_lib}")/$(readelf -d "${_lib}" | grep -Po 'SONAME.*: \[\K[^]]*' || true)
        _base=$(echo ${_soname} | sed -r 's/(.*)\.so.*/\1.so/')
        [[ -e "${_soname}" ]] || sudo ln -s $(basename "${_lib}") "${_soname}"
        [[ -e "${_base}" ]] || sudo ln -s $(basename "${_soname}") "${_base}"
    done
}


create_links_32() {
    # create soname links
    for _lib in $(find "${pkgdir}" -name '*.so*' | grep -v 'xorg/'); do
        _soname=$(dirname "${_lib}")/$(readelf -d "${_lib}" | grep -Po 'SONAME.*: \[\K[^]]*' || true)
        _base=$(echo ${_soname} | sed -r 's/(.*).so.*/\1.so/')
        [[ -e "${_soname}" ]] || sudo ln -s $(basename "${_lib}") "${_soname}"
        [[ -e "${_base}" ]] || sudo ln -s $(basename "${_soname}") "${_base}"
    done
}


prepare() {

# PATCHES
    wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/raw/main/nvidia-drivers-470.223.02-gpl-pfn_valid.patch
    wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/raw/main/nvidia.rules
    wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/raw/main/nvidia-drm-outputclass.conf
    wget https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/raw/main/nvidia-utils.sysusers

    # PREPARE
    sh "${_pkg}.run" --extract-only
    cd "${_pkg}"
    tar -xf nvidia-persistenced-init.tar.bz2

    cd kernel

    # Fix incompat with Linux 6.6.15 and 6.7.3
    # From Gentoo at https://github.com/gentoo/gentoo/commit/c64caf5352e8b82edbaa2204aaf055cbcabfc8d1
    patch --no-backup-if-mismatch -Np2 -i "$srcdir/nvidia-drivers-470.223.02-gpl-pfn_valid.patch"

    sed -i "s/__VERSION_STRING/${pkgver}/" dkms.conf
    sed -i 's/__JOBS/`nproc`/' dkms.conf
    sed -i 's/__DKMS_MODULES//' dkms.conf
    sed -i '$iBUILT_MODULE_NAME[0]="nvidia"\
DEST_MODULE_LOCATION[0]="/kernel/drivers/video"\
BUILT_MODULE_NAME[1]="nvidia-uvm"\
DEST_MODULE_LOCATION[1]="/kernel/drivers/video"\
BUILT_MODULE_NAME[2]="nvidia-modeset"\
DEST_MODULE_LOCATION[2]="/kernel/drivers/video"\
BUILT_MODULE_NAME[3]="nvidia-drm"\
DEST_MODULE_LOCATION[3]="/kernel/drivers/video"\
BUILT_MODULE_NAME[4]="nvidia-peermem"\
DEST_MODULE_LOCATION[4]="/kernel/drivers/video"' dkms.conf

    # Gift for linux-rt guys
    sed -i 's/NV_EXCLUDE_BUILD_MODULES/IGNORE_PREEMPT_RT_PRESENCE=1 NV_EXCLUDE_BUILD_MODULES/' dkms.conf
}


package() {

cd ${_pkg}

# Create some paths
#sudo mkdir -p ${pkgdir}/usr/lib/xorg/modules/drivers
#sudo mkdir -p ${pkgdir}/usr/lib/x86_64-linux-gnu
#sudo mkdir -p ${pkgdir}/usr/bin
#sudo mkdir -p ${pkgdir}/usr/lib/Nvidia/xorg
#sudo mkdir -p ${pkgver}usr/share/vulkan/implicit_layer.d
#sudo mkdir -p ${pkgdir}/usr/share/man/man1/
#sudo mkdir -p ${pkgver}/usr/lib/systemd/system

# Check http://us.download.nvidia.com/XFree86/Linux-x86_64/${pkgver}/README/installedcomponents.html
# for hints on what needs to be installed where.

# X driver
    sudo install -Dm755 nvidia_drv.so "${pkgdir}/usr/lib/xorg/modules/drivers/nvidia_drv.so"

# Wayland/GBM
    sudo install -Dm755 libnvidia-egl-gbm.so.1* -t "${pkgdir}/usr/lib/x86_64-linux-gnu/"
    sudo install -Dm644 15_nvidia_gbm.json "${pkgdir}/usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json"
    sudo mkdir -p "${pkgdir}/usr/lib/x86_64-linux-gnu/gbm"
    sudo ln -sr "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/gbm/nvidia-drm_gbm.so"

# firmware
    sudo install -Dm644 -t "${pkgdir}/usr/lib/firmware/nvidia/${pkgver}/" firmware/*.bin

# Libnvidia-gtk (unactivated for nvidia-settings from source)

    #sudo install -Dm755 "libnvidia-gtk2.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-gtk2.so.${pkgver}"
    #sudo install -Dm755 "libnvidia-gtk3.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-gtk3.so.${pkgver}"

# GLX extension module for X
    sudo install -Dm755 "libglxserver_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/nvidia/xorg/libglxserver_nvidia.so.${pkgver}"
# Ensure that X finds glx
    sudo ln -s "libglxserver_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/nvidia/xorg/libglxserver_nvidia.so.1"
    sudo ln -s "libglxserver_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/nvidia/xorg/libglxserver_nvidia.so"

    sudo install -Dm755 "libGLX_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.${pkgver}"

# OpenGL libraries
    sudo install -Dm755 "libEGL_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libEGL_nvidia.so.${pkgver}"
    sudo install -Dm755 "libGLESv1_CM_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libGLESv1_CM_nvidia.so.${pkgver}"
    sudo install -Dm755 "libGLESv2_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libGLESv2_nvidia.so.${pkgver}"
    sudo install -Dm644 "10_nvidia.json" "${pkgdir}/usr/share/glvnd/egl_vendor.d/10_nvidia.json"

# OpenGL core library
    sudo install -Dm755 "libnvidia-glcore.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-glcore.so.${pkgver}"
    sudo install -Dm755 "libnvidia-eglcore.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-eglcore.so.${pkgver}"
    sudo install -Dm755 "libnvidia-glsi.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-glsi.so.${pkgver}"

# misc
    sudo install -Dm755 "libnvidia-api.so.1" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-api.so.1"
    sudo install -Dm755 "libnvidia-fbc.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.${pkgver}"
    sudo install -Dm755 "libnvidia-encode.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-encode.so.${pkgver}"
    sudo install -Dm755 "libnvidia-cfg.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-cfg.so.${pkgver}"
    sudo install -Dm755 "libnvidia-ml.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-ml.so.${pkgver}"
    sudo install -Dm755 "libnvidia-glvkspirv.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-glvkspirv.so.${pkgver}"
    sudo install -Dm755 "libnvidia-allocator.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.${pkgver}"
    sudo install -Dm755 "libnvidia-gpucomp.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-gpucomp.so.${pkgver}"

# Vulkan ICD
    sudo install -Dm644 "nvidia_icd.json" "${pkgdir}/usr/share/vulkan/icd.d/nvidia_icd.json"
    sudo install -Dm644 "nvidia_layers.json" "${pkgdir}/usr/share/vulkan/implicit_layer.d/nvidia_layers.json"

# VDPAU
    sudo install -Dm755 "libvdpau_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/vdpau/libvdpau_nvidia.so.${pkgver}"

# nvidia-tls library
    sudo install -Dm755 "libnvidia-tls.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-tls.so.${pkgver}"

# CUDA
    sudo install -Dm755 "libcuda.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libcuda.so.${pkgver}"
    sudo install -Dm755 "libnvcuvid.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvcuvid.so.${pkgver}"
    sudo install -Dm755 "libcudadebugger.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libcudadebugger.so.${pkgver}"

# NVVM Compiler library loaded by the CUDA driver to do JIT link-time-optimization
    sudo install -Dm644 "libnvidia-nvvm.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-nvvm.so.${pkgver}"

# PTX JIT Compiler (Parallel Thread Execution (PTX) is a pseudo-assembly language for CUDA)
    sudo install -Dm755 "libnvidia-ptxjitcompiler.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.${pkgver}"

# raytracing
    sudo install -Dm755 "nvoptix.bin" "${pkgdir}/usr/share/nvidia/nvoptix.bin"
    sudo install -Dm755 "libnvoptix.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvoptix.so.${pkgver}"
    sudo install -Dm755 "libnvidia-rtcore.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-rtcore.so.${pkgver}"

# NGX
    sudo install -Dm755 nvidia-ngx-updater "${pkgdir}/usr/bin/nvidia-ngx-updater"
    sudo install -Dm755 "libnvidia-ngx.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-ngx.so.${pkgver}"
    sudo install -Dm755 _nvngx.dll "${pkgdir}/usr/lib/x86_64-linux-gnu/nvidia/wine/_nvngx.dll"
    sudo install -Dm755 nvngx.dll "${pkgdir}/usr/lib/x86_64-linux-gnu/nvidia/wine/nvngx.dll"

# Optical flow
    sudo install -Dm755 "libnvidia-opticalflow.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-opticalflow.so.${pkgver}"

# Cryptography library wrapper
    ls libnvidia-pkcs*
    ls *openssl*
    sudo install -Dm755 "libnvidia-pkcs11.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-pkcs11.so.${pkgver}"
    sudo install -Dm755 "libnvidia-pkcs11-openssl3.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-pkcs11-openssl3.so.${pkgver}"

# Debug
    sudo install -Dm755 nvidia-debugdump "${pkgdir}/usr/bin/nvidia-debugdump"

# nvidia-xconfig
    sudo install -Dm755 nvidia-xconfig "${pkgdir}/usr/bin/nvidia-xconfig"
    sudo install -Dm644 nvidia-xconfig.1.gz "${pkgdir}/usr/share/man/man1/nvidia-xconfig.1.gz"

# nvidia-bug-report
    sudo install -Dm755 nvidia-bug-report.sh "${pkgdir}/usr/bin/nvidia-bug-report.sh"

# nvidia-smi
    sudo install -Dm755 nvidia-smi "${pkgdir}/usr/bin/nvidia-smi"
    sudo install -Dm644 nvidia-smi.1.gz "${pkgdir}/usr/share/man/man1/nvidia-smi.1.gz"

# nvidia-cuda-mps
    sudo install -Dm755 nvidia-cuda-mps-server "${pkgdir}/usr/bin/nvidia-cuda-mps-server"
    sudo install -Dm755 nvidia-cuda-mps-control "${pkgdir}/usr/bin/nvidia-cuda-mps-control"
    sudo install -Dm644 nvidia-cuda-mps-control.1.gz "${pkgdir}/usr/share/man/man1/nvidia-cuda-mps-control.1.gz"

# nvidia-modprobe
# This should be removed if nvidia fixed their uvm module!
    sudo install -Dm4755 nvidia-modprobe "${pkgdir}/usr/bin/nvidia-modprobe"
    sudo install -Dm644 nvidia-modprobe.1.gz "${pkgdir}/usr/share/man/man1/nvidia-modprobe.1.gz"

# nvidia-persistenced
    sudo install -Dm755 nvidia-persistenced "${pkgdir}/usr/bin/nvidia-persistenced"
    sudo install -Dm644 nvidia-persistenced.1.gz "${pkgdir}/usr/share/man/man1/nvidia-persistenced.1.gz"
    sudo install -Dm644 nvidia-persistenced-init/systemd/nvidia-persistenced.service.template "${pkgdir}/usr/lib/systemd/system/nvidia-persistenced.service"
    sudo sed -i 's/__USER__/nvidia-persistenced/' "${pkgdir}/usr/lib/systemd/system/nvidia-persistenced.service"

# application profiles
    sudo install -Dm644 nvidia-application-profiles-${pkgver}-rc "${pkgdir}/usr/share/nvidia/nvidia-application-profiles-${pkgver}-rc"
    sudo install -Dm644 nvidia-application-profiles-${pkgver}-key-documentation "${pkgdir}/usr/share/nvidia/nvidia-application-profiles-${pkgver}-key-documentation"

    sudo install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/nvidia-utils/LICENSE"
    sudo install -Dm644 README.txt "${pkgdir}/usr/share/doc/nvidia/README"
    sudo install -Dm644 NVIDIA_Changelog "${pkgdir}/usr/share/doc/nvidia/NVIDIA_Changelog"
    sudo cp -r html "${pkgdir}/usr/share/doc/nvidia/"
    sudo ln -s nvidia "${pkgdir}/usr/share/doc/nvidia-utils"

# new power management support
    sudo install -Dm644 systemd/system/*.service -t "${pkgdir}/usr/lib/systemd/system"
    sudo install -Dm755 systemd/system-sleep/nvidia "${pkgdir}/usr/lib/systemd/system-sleep/nvidia"
    sudo install -Dm755 systemd/nvidia-sleep.sh "${pkgdir}/usr/bin/nvidia-sleep.sh"
    sudo install -Dm755 nvidia-powerd "${pkgdir}/usr/bin/nvidia-powerd"
    sudo install -Dm644 nvidia-dbus.conf "${pkgdir}"/usr/share/dbus-1/system.d/nvidia-dbus.conf

# distro specific files must be installed in /usr/share/X11/xorg.conf.d
    sudo install -Dm644 "${srcdir}/nvidia-drm-outputclass.conf" "${pkgdir}/usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf"

    sudo install -Dm644 "${srcdir}/nvidia-utils.sysusers" "${pkgdir}/usr/lib/sysusers.d/$pkgname.conf"

    sudo install -Dm644 "${srcdir}/nvidia.rules" "$pkgdir"/usr/lib/udev/rules.d/60-nvidia.rules

    echo "blacklist nouveau" | sudo install -Dm644 /dev/stdin "${pkgdir}/usr/lib/modprobe.d/${pkgname}.conf"
    echo "nvidia-uvm" | sudo install -Dm644 /dev/stdin "${pkgdir}/usr/lib/modules-load.d/${pkgname}.conf"

# OpenCL
    sudo install -Dm644 nvidia.icd "${pkgdir}/etc/OpenCL/vendors/nvidia.icd"
    sudo install -Dm755 "libnvidia-opencl.so.${pkgver}" "${pkgdir}/usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.${pkgver}"

    sudo mkdir -p "${pkgdir}/usr/share/licenses"
    sudo ln -s nvidia-utils "${pkgdir}/usr/share/licenses/opencl-nvidia"

    create_links

# DKMS
    sudo install -dm 755 "${pkgdir}"/usr/src
    sudo cp -dr --no-preserve='ownership' kernel "${pkgdir}/usr/src/nvidia-${pkgver}"

    sudo install -Dt "${pkgdir}/usr/share/licenses/${pkgname}" -m644 "${srcdir}/${_pkg}/LICENSE"

# LIB32 : /usr/lib/i386-linux-gnu/
    cd 32

    # OpenCL
    sudo install -D -m755 "libnvidia-opencl.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-opencl.so.${pkgver}"

    sudo mkdir -p "${pkgdir}/usr/share/licenses"
    sudo ln -s $_pkgbasename "${pkgdir}/usr/share/licenses/lib32-opencl-nvidia"

    # Check http://us.download.nvidia.com/XFree86/Linux-x86_64/${pkgver}/README/installedcomponents.html
    # for hints on what needs to be installed where.

    sudo install -D -m755 "libGLX_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libGLX_nvidia.so.${pkgver}"

    # OpenGL libraries
    sudo install -D -m755 "libEGL_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libEGL_nvidia.so.${pkgver}"
    sudo install -D -m755 "libGLESv1_CM_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libGLESv1_CM_nvidia.so.${pkgver}"
    sudo install -D -m755 "libGLESv2_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libGLESv2_nvidia.so.${pkgver}"

    # OpenGL core library
    sudo install -D -m755 "libnvidia-glcore.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-glcore.so.${pkgver}"
    sudo install -D -m755 "libnvidia-eglcore.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-eglcore.so.${pkgver}"
    sudo install -D -m755 "libnvidia-glsi.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-glsi.so.${pkgver}"

    # misc
    sudo install -D -m755 "libnvidia-fbc.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-fbc.so.${pkgver}"
    sudo install -D -m755 "libnvidia-encode.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-encode.so.${pkgver}"
    sudo install -D -m755 "libnvidia-ml.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-ml.so.${pkgver}"
    sudo install -D -m755 "libnvidia-glvkspirv.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-glvkspirv.so.${pkgver}"
    sudo install -D -m755 "libnvidia-allocator.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-allocator.so.${pkgver}"
    sudo install -D -m755 "libnvidia-gpucomp.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-gpucomp.so.${pkgver}"

    # VDPAU
    sudo install -D -m755 "libvdpau_nvidia.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/vdpau/libvdpau_nvidia.so.${pkgver}"

    # nvidia-tls library
    sudo install -D -m755 "libnvidia-tls.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-tls.so.${pkgver}"

    # CUDA
    sudo install -D -m755 "libcuda.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libcuda.so.${pkgver}"
    sudo install -D -m755 "libnvcuvid.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvcuvid.so.${pkgver}"

    # PTX JIT Compiler (Parallel Thread Execution (PTX) is a pseudo-assembly language for CUDA)
    sudo install -D -m755 "libnvidia-ptxjitcompiler.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-ptxjitcompiler.so.${pkgver}"

    # Optical flow
    sudo install -D -m755 "libnvidia-opticalflow.so.${pkgver}" "${pkgdir}/usr/lib/i386-linux-gnu/libnvidia-opticalflow.so.${pkgver}"

    #sudo rm -rf "${pkgdir}"/usr/{include,share,bin}
    sudo mkdir -p "${pkgdir}/usr/share/licenses"
    sudo ln -s $_pkgbasename "${pkgdir}/usr/share/licenses/${pkgname}"

# CREATE .SO SYMLINKS
    create_links_32

}

post_upgrade() {
  echo "If you run into trouble with CUDA not being available, run nvidia-modprobe first."
  echo "If you use GDM on Wayland, you might have to run systemctl enable --now nvidia-resume.service"



}
# For the latter nore, see also https://gitlab.gnome.org/GNOME/gdm/-/issues/784

pre_install() {
#!/bin/bash
DKMS_NAME=$(dkms status nvidia | cut -d "," -f1 | cut -d "/" -f1)
DKMS_VERSION=$(dkms status nvidia | cut -d "," -f1 | cut -d "/" -f1)
if [[ "$DKMS_NAME" == "nvidia" ]]; then
         dkms remove -m $DKMS_NAME -v $DKMS_VERSION --all || true
fi

}

post_install() {

set -e

DKMS_NAME=nvidia
DKMS_PACKAGE_NAME=$DKMS_NAME-dkms
DKMS_VERSION=545.29.06

dkms add -m $DKMS_NAME -v $DKMS_VERSION
dkms build -m $DKMS_NAME -v $DKMS_VERSION && dkms install -m $DKMS_NAME -v $DKMS_VERSION --force || true

post_upgrade

}

post_remove() {

}
