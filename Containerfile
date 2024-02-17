FROM scratch
COPY mnt /
COPY rootfs /
# The rootfs can't be modified and systemd can't create them implicitly.
# That's why we have to create them as part of the rootfs.
RUN mkdir /efi

# Normal post installation steps.
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN locale-gen
RUN systemctl enable systemd-timesyncd.service

RUN mkdir /sysroot
RUN ostree admin init-fs /
RUN ostree admin os-init bouhaa-os