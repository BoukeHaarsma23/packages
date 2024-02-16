pacman-key --init
pacman-key --populate
echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# This allows us to use this image for committing as well.
pacman --noconfirm -Syu arch-install-scripts grub ostree rsync

# This allows using pacstrap -N in a rootless container.
echo 'root:1000:5000' > /etc/subuid
echo 'root:1000:5000' > /etc/subgid

# We need the ostree hook.
install -d /mnt/etc
cp /workdir/rootfs/etc/mkinitcpio.conf /mnt/etc/

# Install packages.
pacstrap -c -G -M mnt \
	base \
	linux \
	intel-ucode \
	amd-ucode \
	efibootmgr \
	grub \
	ostree \
	which