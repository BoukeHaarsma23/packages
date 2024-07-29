# This allows using pacstrap -N in a rootless container.
echo 'root:1000:5000' > /etc/subuid
echo 'root:1000:5000' > /etc/subgid

cp -r /workdir/repo /tmp/repo

repo-add /tmp/repo/chos.db.tar.gz /tmp/repo/*.pkg.*
echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
# Set yesterday archive to have 'fixed version'
echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
# Add custom repo
sed -i '/^\[core\]/s/^/\[chos\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf
# enable multilib
echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf

# Init keys
pacman-key --init
pacman-key --populate archlinux

# This allows us to use pacstrap
pacman --noconfirm -Syyuu arch-install-scripts

# Install packages in our mount which we copy into a container
pacstrap -c -G mnt \
	amd-ucode \
	base \
	cpupower \
	distrobox \
	efibootmgr \
	flatpak \
	gamescope \
	linux \
	lib32-mesa \
	lib32-vulkan-mesa-layers \
	lib32-vulkan-radeon \
	mesa \
	mesa-vdpau \
	nano \
	podman \
	pikaur \
	steam \
	which \
	vulkan-mesa-layers \
	vulkan-radeon \
	zenergy-dkms-git