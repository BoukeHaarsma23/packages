FROM archlinux:base-devel
COPY repo /tmp/repo
COPY rootfs/etc/pacman.conf /etc/pacman.conf

RUN repo-add /tmp/repo/bouhaa.db.tar.gz /tmp/repo/*.pkg.*
RUN echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
    # Set yesterday archive to have 'fixed version'
    echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    # Cannot check space in chroot
    sed -i '/CheckSpace/s/^/#/g' /etc/pacman.conf && \
    sed -i '/^\[core\]/s/^/\[bouhaa\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf

RUN pacman-key --init && \
    pacman --noconfirm -Sy archlinux-keyring && \
    pacman-key --populate archlinux && \
    pacman --noconfirm -Syyuu && \
    pacman --noconfirm -S \
    arch-install-scripts \
    btrfs-progs \
    git \
    sudo \
    pikaur

RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd build -G wheel -m

# Add a fake systemd-run script to workaround pikaur requirement.
RUN echo -e "#!/bin/bash\nif [[ \"$1\" == \"--version\" ]]; then echo 'fake 244 version'; fi\nmkdir -p /var/cache/pikaur\n" >> /usr/bin/systemd-run && \
    chmod +x /usr/bin/systemd-run

USER build
ENV BUILD_USER "build"
ENV GNUPGHOME  "/etc/pacman.d/gnupg"
# Built image will be moved here. This should be a host mount to get the output.
ENV OUTPUT_DIR /output

WORKDIR /workdir