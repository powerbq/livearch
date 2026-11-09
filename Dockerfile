FROM archlinux:base

WORKDIR /usr/local/src/build

COPY aur/ aur/
COPY opt/ opt/
COPY patch/ /usr/share/livearch/patch/
COPY PKGBUILD-* boot.sh cleanup.sh custom.sh entrypoint.sh mirror.sh packages.sh save.sh excludes.txt .
COPY boot/init /usr/share/livearch/init
COPY boot/install /usr/lib/initcpio/install/livearch
COPY boot/sd-install /usr/lib/initcpio/install/sd-livearch
COPY boot/runscript /usr/lib/initcpio/hooks/livearch
COPY boot/hook.preset /etc/mkinitcpio.d/linux.preset
COPY boot/initrd-livearch.service /usr/lib/systemd/system/initrd-livearch.service
COPY boot/initrd-root-fs.target.wants /usr/lib/systemd/system/initrd-root-fs.target.wants

ENTRYPOINT ["./entrypoint.sh"]

ENV LC_ALL=C
ENV MIRROR_COUNTRY_CODE=
ENV AUR_PACKAGES=
ENV BOOT_SKIP_HOOKS=
ENV BOOT_ADD_HOOKS=
ENV FILENAME_SUFFIX=latest
ENV SQUASHFS_BLOCK_SIZE=128K
ENV SQUASHFS_COMP=zstd
ENV SQUASHFS_ADDITIONAL_OPTIONS=
