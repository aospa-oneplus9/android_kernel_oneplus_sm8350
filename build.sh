#!/usr/bin/env bash

TARGET_ARCH=arm64;
TARGET_CC=clang;
TRAGET_CLANG_TRIPLE=aarch64-linux-gnu-;
TARGET_CROSS_COMPILE=aarch64-linux-gnu-;
TARGET_CROSS_COMPILE_COMPAT=arm-linux-gnueabi-;
THREAD=$(nproc --all);
CC_ADDITIONAL_FLAGS="LLVM_IAS=1 LLVM=1 LD=ld.lld";
TARGET_OUT=out;
FINAL_KERNEL_BUILD_PARA="ARCH=$TARGET_ARCH \
                         CC=$TARGET_CC \
                         CROSS_COMPILE=$TARGET_CROSS_COMPILE \
                         CROSS_COMPILE_COMPAT=$TARGET_CROSS_COMPILE_COMPAT \
                         CLANG_TRIPLE=$TARGET_CLANG_TRIPLE \
                         $CC_ADDITIONAL_FLAGS \
                         -j$THREAD \
                         O=out";

TARGET_KERNEL_FILE=out/arch/arm64/boot/Image;
TARGET_KERNEL_DTB=out/arch/arm64/boot/dtb;
TARGET_KERNEL_DTBO=out/arch/arm64/boot/dtbo.img

DEFCONFIG="vendor/lahaina-qgki_defconfig";

if ! make $FINAL_KERNEL_BUILD_PARA $DEFCONFIG; then
    exit 1
fi

if ! make $FINAL_KERNEL_BUILD_PARA; then
    exit 2
fi

rm -r out/ak3
cp -r ak3 out/

cp out/arch/arm64/boot/Image out/ak3/Image
cp out/arch/arm64/boot/dtbo.img out/ak3/dtbo.img
find out/arch/arm64/boot/dts/vendor -name '*.dtb' -exec cat {} + > out/ak3/dtb;

cd out/ak3
zip -r9 lemonade-$(/bin/date -u '+%Y%m%d-%H%M').zip .

