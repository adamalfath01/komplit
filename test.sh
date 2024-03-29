#!/bin/bash
#
# Compile script for MoeKernel🐇
# Copyright (C) 2020-2021 Adithya R.

SECONDS=0
ZIPNAME="Muse-$(date '+%Y%m%d').zip"
export KBUILD_BUILD_USER="RoniW43"
export KBUILD_BUILD_HOST="@ronisaja"
export PATH="toolchain/nusantaraclang12/bin:$PATH"
export LD_LIBRARY_PATH="toolchain/nusantaraclang12/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$(toolchain/nusantaraclang12/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=out

# Clone toolchain
if ! [ -d "../toolchain" ]; then
    wget -O proton.tar.zst https://github.com/kdrag0n/proton-clang/archive/20200801.tar.gz
    mkdir -p ../toolchain/clang12.0
    sudo tar -I zstd -xvf proton.tar.zst -C ../toolchain/clang --strip-components=1
else
    echo "${bold}Folder Toolchain Sudah Tersedia, Tidak Perlu Di Clone${normal}"
fi

# Functions
clang_build () {
    make -j4 O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
					      LD="ld.lld" \
			              AS="llvm-as" \
						  STRIP="llvm-strip" \
			              OBJCOPY="llvm-objcopy" \
			              OBJDUMP="llvm-objdump" \
						  CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=aarch64-linux-gnu-  \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
clang_build

git clone --depth=1 https://github.com/roniwae/AnyKernel3.git -b MIUI AnyKernel3
          if [[ -f out/arch/arm64/boot/Image.gz-dtb ]]; then
            cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
          elif [[ -f out/arch/arm64/boot/Image-dtb ]]; then
            cp out/arch/arm64/boot/Image-dtb AnyKernel3/Image-dtb
          elif [[ -f out/arch/arm64/boot/Image.gz ]]; then
            cp out/arch/arm64/boot/Image.gz AnyKernel3/Image.gz
          elif [[ -f out/arch/arm64/boot/Image ]]; then
            cp out/arch/arm64/boot/Image AnyKernel3/Image
          fi
          if [ -f out/arch/arm64/boot/dtbo.img ]; then
            cp out/arch/arm64/boot/dtbo.img AnyKernel3/dtbo.img
          fi

    cd AnyKernel3
    git checkout master &> /dev/null
    zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
    cd ..
    rm -rf AnyKernel3
    rm -rf out/arch/arm64/boot
    echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    echo "Zip: $ZIPNAME"
else
    echo -e "\nCompilation failed!"
    exit 1
fi
