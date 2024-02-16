FROM archlinux:latest AS builder

# The bootstrap image is very minimal and we still have to setup pacman.
RUN pacman-key --init
RUN pacman-key --populate
RUN echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# This allows us to use this image for committing as well.
RUN pacman --noconfirm -Syu arch-install-scripts grub ostree rsync

# This allows using this container to make a deployment.
RUN ln -s sysroot/ostree /ostree

# This allows using pacstrap -N in a rootless container.
RUN echo 'root:1000:5000' > /etc/subuid
RUN echo 'root:1000:5000' > /etc/subgid

# We need the ostree hook.
RUN install -d /mnt/etc
COPY rootfs/etc/mkinitcpio.conf /mnt/etc/

# Install packages.
RUN pacstrap -c -G -M /mnt \
	base \
	linux \
	intel-ucode \
	amd-ucode \
	efibootmgr \
	grub \
	ostree \
	which

# Turn the pacstrapped rootfs into a container image.
FROM scratch
COPY --from=builder /mnt /

# The rootfs can't be modified and systemd can't create them implicitly.
# That's why we have to create them as part of the rootfs.
RUN mkdir /efi

# Normal post installation steps.
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
RUN locale-gen
RUN systemctl enable systemd-timesyncd.service