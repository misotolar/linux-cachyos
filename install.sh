#!/bin/sh

if [ -f "/sys/firmware/acpi/platform_profile" ]; then
    echo 'performance' | sudo tee -i /sys/firmware/acpi/platform_profile >/dev/null
fi

rm -rf "$PWD"/{makepkg,01*.patch,config,auto-cpu-optimization.sh}
updpkgsums; makepkg --printsrcinfo > .SRCINFO; BUILDDIR="$PWD/makepkg" _LTO_CLANG="FULL" makepkg -cfisr
