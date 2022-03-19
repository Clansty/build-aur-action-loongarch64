FROM archlinux:latest

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /tmp

RUN pacman-key --init
RUN pacman -Syu --noconfirm --needed base-devel wget

RUN wget https://github.com/sunhaiyong1978/CLFS-for-LoongArch/releases/download/20210903/qemu-x86_64-to-loongarch64 -O /usr/local/bin/qemu-loongarch64 && \
    chmod +x /usr/local/bin/qemu-loongarch64

COPY qemu-loongarch64.conf /etc/binfmt.d/qemu-loongarch64.conf

RUN wget https://github.com/archlinux-loongarch64/archlinux-loongarch64-base/releases/download/v0.2/archlinux-bootstrap-2022.03.18-loongarch64.tar.gz -O /tmp/bootstrap.tar.gz && \
    tar -xzf /tmp/bootstrap.tar.gz -C / && \
    rm -rf /tmp/bootstrap.tar.gz && \
    cp /usr/local/bin/qemu-loongarch64 /loongarch64-root/usr/local/bin/qemu-loongarch64

WORKDIR /loongarch64-root
COPY tls-ca-bundle.pem etc/ca-certificates/extracted/tls-ca-bundle.pem



COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"] 
