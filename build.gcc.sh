#!/usr/bin/env bash

defconfig_original="vendor/lahaina-qgki_defconfig"
defconfig_gcov="vendor/lahaina-qgki_gcov_defconfig"
defconfig_pgo="vendor/lahaina-qgki_pgo_defconfig"

mode="$1"
echo "Mode: $mode"
if [ "$mode" = "gcov" ]; then
    cp arch/arm64/configs/$defconfig_original arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_DEBUG_KERNEL=y"     >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_DEBUG_FS=y"         >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_GCOV_KERNEL=y"      >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_GCOV_PROFILE_ALL=y" >> arch/arm64/configs/$defconfig_gcov
    defconfig=$defconfig_gcov
elif [ "$mode" = "pgo" ]; then
    cp arch/arm64/configs/$defconfig_original arch/arm64/configs/$defconfig_pgo
    echo "CONFIG_PGO=y"              >> arch/arm64/configs/$defconfig_pgo
    defconfig=$defconfig_pgo
else
    defconfig=$defconfig_original
fi

arch_opts="ARCH=arm64 SUBARCH=arm64"

export CROSS_COMPILE="aarch64-elf-"

if ! make O=out $arch_opts "$defconfig"; then
    exit 1
fi

if ! make O=out $arch_opts -j"$(nproc --all)"; then
    exit 2
fi

rm -r out/ak3
cp -r ak3 out/

cp out/arch/arm64/boot/Image out/ak3/Image
cp out/arch/arm64/boot/dtbo.img out/ak3/dtbo.img
find out/arch/arm64/boot/dts/vendor -name '*.dtb' -exec cat {} + > out/ak3/dtb;

cd out/ak3
zip -r9 lemonade-$(/bin/date -u '+%Y%m%d-%H%M').zip .

