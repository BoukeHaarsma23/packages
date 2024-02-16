# This allows using pacstrap -N in a rootless container.
echo 'root:1000:5000' > /etc/subuid
echo 'root:1000:5000' > /etc/subgid

cp /workdir/repo /tmp/repo

repo-add /tmp/repo/bouhaa.db.tar.gz /tmp/repo/*.pkg.*
echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
# Set yesterday archive to have 'fixed version'
echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
# Cannot check space in chroot
sed -i '/CheckSpace/s/^/#/g' /etc/pacman.conf && \
sed -i '/^\[core\]/s/^/\[bouhaa\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf

# This allows us to use this image for committing as well.
pacman --noconfirm -Syyuu arch-install-scripts grub ostree rsync

# We need the ostree hook.
install -d /mnt/etc
cp /workdir/rootfs/etc/mkinitcpio.conf /mnt/etc/

# Install packages.
pacstrap -c -G -M mnt \
	base \
	linux \
	efibootmgr \
	grub \
	ostree \
	which