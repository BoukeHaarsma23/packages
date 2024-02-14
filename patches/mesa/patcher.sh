# /bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cp -rv $1/$2 $3/$2-chimeraos
# Suffix package with -chimeraos
sed -i '/^pkgbase=/s/$/-chimeraos/' $3/$2-chimeraos/PKGBUILD
# In the prepare function replace
# echo "$pkgver-arch$epoch.$pkgrel" >VERSION
sed -i '/.*echo \"\$pkgver.*/s/arch/chos/' $3/$2-chimeraos/PKGBUILD

# Add patches to sources
# https://stackoverflow.com/a/52057667
#sed '/^source.*/{:a;/)/!{N;ba};s/)/bla)/;}' PKGBUILD
#sed -i '/^source.*/{:a;/)/!{N;ba};s/)/bla)/;}' PKGBUILD

#patches="0001-vulkan-wsi-wayland-refactor-wayland-dispatch-code.patch\n0002-vulkan-wsi-wayland-Use-commit_timing-commit_queue-pr.patch\n0003-hack-rip-out-commit-timing-v1.patch\n0004-wsi-Use-vendored-gamescope-commit-queue-v1-protocol.patch\n0005-STEAMOS-Dynamic-swapchain-override-for-gamescope-lim.patch"
patches=find *.patch -type f -printf "%f\n"
sed -i '/^source.*/{:a;/)/!{N;ba};s/)/'${patches}'\n)\n/;}' $3/$2-chimeraos/PKGBUILD
pushd $3/$2-chimeraos
# plumb patches in folder and update checksums
cp -v ${SCRIPT_DIR}/*.patch .
updpkgsums