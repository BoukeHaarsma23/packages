FROM scratch
COPY mnt /
COPY rootfs /
# OSTree: Prepare microcode and initramfs
RUN moduledir=$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d) && \
    cat /boot/*-ucode.img \
    /boot/initramfs-linux-fallback.img \
    > ${moduledir}/initramfs.img

# OSTree: Bootloader integration
RUN curl https://raw.githubusercontent.com/ostreedev/ostree/v2023.6/src/boot/grub2/grub2-15_ostree -o /etc/grub.d/15_ostree && \
    chmod +x /etc/grub.d/15_ostree

# Podman: native Overlay Diff for optimal Podman performance
RUN echo "options overlay metacopy=off redirect_dir=off" > /etc/modprobe.d/disable-overlay-redirect-dir.conf
# The rootfs can't be modified and systemd can't create them implicitly.
# That's why we have to create them as part of the rootfs.
RUN mkdir /efi

# Normal post installation steps.
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN locale-gen
RUN systemctl enable systemd-timesyncd.service
RUN ostree admin init-fs /
RUN ostree admin os-init bouhaa-os
RUN ostree commit
