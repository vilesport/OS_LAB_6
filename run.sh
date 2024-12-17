#!/bin/sh
DIR1="linux-6.10.2"
DIR2="busybox-1.36.1"
DRV="pid"
ELF="flag_inter"

kernel() {
    if [ ! -d "$DIR1" ]
    then
        if [ ! -e "$DIR1.tar.xz" ]
        then
            echo "$DIR1.tar.xz not found"
            echo "Downloading $DIR1.tar.xz"
            wget cdn.kernel.org/pub/linux/kernel/v6.x/$DIR1.tar.xz
        fi
        echo "Extracting $DIR1.tar.xz" ;
        tar -xf $DIR1.tar.xz
    fi
    cp ./.config_linux ./$DIR1/.config ;
    make --directory=./$DIR1 -j 6 oldconfig ;
    make --directory=./$DIR1 -j 6
}

busybox() {
    if [ ! -d "$DIR2" ]
    then
        if [ ! -e "$DIR2.tar.bz2" ]
        then
            echo "$DIR2.tar.bz2 not found"
            echo "Downloading $DIR2.tar.xz"
            wget busybox.net/downloads/$DIR2.tar.bz2
        fi
        echo "Extracting $DIR2.tar.bz2" ;
        tar -xf $DIR2.tar.bz2
    fi
    mkdir -p ./$DIR2/Final ;
    cp ./.config_busybox ./$DIR2/Final/.config ;
    make --directory=./$DIR2 -j 6 O=./Final/ oldconfig ;
    make --directory=./$DIR2 -j 6 O=./Final/ ;
    make --directory=./$DIR2 -j 6 O=./Final/ install
}

compile() {
    for dir in bin sbin etc proc sys usr/bin usr/sbin drivers; do mkdir -p ./files/_install/$dir; done ;
    cp -r ./$DIR2/Final/_install ./files/ ;
    cp ./$DIR1/arch/x86/boot/bzImage ./files/bzImage ;
    cp ./.init ./files/_install/init ;
    chmod +x ./files/_install/init
    cp ./.makedrivers ./drivers/Makefile ;
    make --directory=./drivers all DRV=$DRV VER=$DIR1 ELF=$ELF;
    cp ./drivers/*.ko ./files/_install/drivers/ ;
    chmod +x ./drivers/$ELF ;
    cp ./drivers/$ELF ./files/_install/ ;
    cd ./files/_install/ ;
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ./../initramfs.cpio.gz ;
    cd ./../..
}

run() {
    qemu-system-x86_64 -kernel ./files/bzImage \
    -nographic \
    -initrd ./files/initramfs.cpio.gz \
    -append "console=ttyS0 nokaslr nokpti quiet"
}

debug() {
    qemu-system-x86_64 -S -s -kernel ./files/bzImage \
    -nographic \
    -initrd ./files/initramfs.cpio.gz \
    -append "console=ttyS0 nokaslr nokpti quiet" \
    -no-reboot
}

_gdb() {
    gdb-multiarch -ex "target remote localhost:1234" -ex "add-symbol-file ./linux-6.10.2/vmlinux"
}

clean() {
    make --directory=./drivers clean DRV=$DRV VER=$DIR1 ELF=$ELF;
}

_end() {
    echo "Done!" ;
    exit 0
}

help() {
    cat README.md
}

if [ $# -eq 0 ]
then
   run ;
   _end
fi

if [ "$1" = "build" ]
then
    mkdir ./files ;
    kernel ; 
    busybox ;
    compile
fi

if [ "$1" = "kernel" ]; then
    kernel
fi

if [ "$1" = "busybox" ]; then
    busybox
fi

if [ "$1" = "compile" ]; then
    compile
fi

if [ "$1" = "debug" ]; then
    debug
fi

if [ "$1" = "clean" ]; then
    clean
fi

if [ "$1" = "gdb" ]; then
    _gdb
fi

if [ "$1" = "help" ]; then
    help
fi

_end
