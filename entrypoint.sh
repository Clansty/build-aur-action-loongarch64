#!/bin/bash

pkgname=$1

useradd builder -m
chroot /loongarch64-root /usr/bin/useradd -m builder
echo PACKAGER=\"$PACKAGER\" > /loongarch64-root/home/builder/.makepkg.conf
echo 'COMPRESSZST=(zstd -19 -c -z -q --threads=0 -)' >> /loongarch64-root/home/builder/.makepkg.conf

if [[ $pkgname != ./* ]];then
  git clone https://aur.archlinux.org/$pkgname.git
fi # 否则为本地包

chmod -R a+rw $pkgname
mv $pkgname /loongarch64-root/home/builder/
cd /loongarch64-root/home/builder/*

mount --bind /loongarch64-root /loongarch64-root
mount --bind /dev /loongarch64-root/dev
mount --bind /proc /loongarch64-root/proc
mount --bind /sys /loongarch64-root/sys

chroot /loongarch64-root /usr/bin/bash -c 'cd /home/builder/* && su builder -c "makepkg -sfA --skipinteg --nodeps"'
echo ::set-output name=filelist::$(sudo --set-home -u builder CARCH=$ARCH makepkg --packagelist | xargs)
