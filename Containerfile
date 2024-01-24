FROM archlinux:latest AS stage1
COPY repo /tmp/repo
RUN repo-add /tmp/repo/bouhaa.db.tar.gz /tmp/repo/*.pkg.*
RUN echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
    # Set yesterday archive to have 'fixed version'
    echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    # Cannot check space in chroot
    sed -i '/CheckSpace/s/^/#/g' /etc/pacman.conf && \
    sed -i '/^\[core\]/s/^/\[bouhaa\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf

RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman --noconfirm -Syyuu arch-install-scripts

RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd build -G wheel -m

# This allows us to use this image for committing as well.
RUN pacman --noconfirm -Syu grub ostree rsync

# This allows using this container to make a deployment.
RUN ln -s sysroot/ostree /ostree

# This allows using pacstrap -N in a rootless container.
RUN echo 'root:1000:5000' > /etc/subuid
RUN echo 'root:1000:5000' > /etc/subgid

# We need the ostree hook.
RUN install -d /mnt/etc

COPY rootfs /mnt/
RUN pacstrap -c -G -M /mnt \
    base \
    linux \
    amd-ucode \
    mesa-git \
    gamescope \
    efibootmgr \
    grub \
    ostree \
    which

# Use the pacstrapped stuff into container image
FROM scratch
COPY --from=stage1 /mnt /

# The rootfs can't be modified and systemd can't create them implicitly.
# That's why we have to create them as part of the rootfs.
RUN mkdir /efi

# Normal post installation steps.
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN locale-gen
RUN systemctl enable systemd-timesyncd.service