# This allows using pacstrap -N in a rootless container.
echo 'root:1000:5000' > /etc/subuid
echo 'root:1000:5000' > /etc/subgid

cp -r /workdir/repo /tmp/repo

repo-add /tmp/repo/bouhaa.db.tar.gz /tmp/repo/*.pkg.*
echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
# Set yesterday archive to have 'fixed version'
echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
# Add custom repo
sed -i '/^\[core\]/s/^/\[bouhaa\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf

# This allows us to use this image for committing as well.
pacman --noconfirm -Syyuu arch-install-scripts grub ostree rsync

# We need the ostree hook.
install -d /mnt/etc
cp /workdir/rootfs/etc/mkinitcpio.conf /mnt/etc/

# Install packages.
pacstrap -c -G mnt \
	amd-ucode \
	base \
	cpupower \
	distrobox \
	efibootmgr \
	flatpak \
	gamescope-git \
	grub \
	linux \
	ostree \
	mesa-chimeraos \
	mesa-chimeraos-vdpau-chimeraos \
	nano \
	podman \
	pikaur \
	steam \
	which \
	vulkan-mesa-layers-chimeraos \
	vulkan-radeon-chimeraos \
	zenergy-dkms-git