
_major=6.14
_minor=4

pkgbase=linux-cachyos
if [[ ! -z "$KBUILD_BUILD_HOST" ]]; then
    pkgbase="linux-cachyos-$KBUILD_BUILD_HOST"
fi

pkgname=("$pkgbase" "$pkgbase-headers")
if [[ ! -z "$KBUILD_BUILD_DEBUG" ]]; then
    pkgname+=("$pkgbase-dbg")
fi

pkgdesc='Linux BORE + LTO + Cachy Sauce Kernel by CachyOS with other patches and improvements'
pkgver="$_major.$_minor"
pkgrel=1

url="https://github.com/misotolar/linux-cachyos"
license=('GPL2')
arch=(
    x86_64
    x86_64_v3
)

_srcdir="linux-$pkgver"
_kernel="https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x"

_cachyos="7337274fcb2b8bfd6238660d3b3fb3fc375159ee"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="b2f31795ab58ef9d3b9e26e7687d77d249eb740b"
_patches="https://raw.githubusercontent.com/cachyos/kernel-patches/$_patches/$_major"

makedepends=(
    bc
    clang
    cpio
    libelf
    lld
    llvm
    pahole
    perl
    python
    rust
    rust-bindgen
    rust-src
    tar
    xz
    zstd
)

options=(
    !debug
    !strip
)

source=(
    "$_kernel/$_srcdir.tar.xz" "$_kernel/$_srcdir.tar.sign"
    "$_cachyos/config" "$_cachyos/auto-cpu-optimization.sh" 'config.sh' 'config.trinity.sh'
    '0101-CACHYOS-cachyos-base-all.patch'::"$_patches/all/0001-cachyos-base-all.patch"
    '0102-CACHYOS-bore-cachy.patch'::"$_patches/sched/0001-bore-cachy.patch"
    '0103-CACHYOS-dkms-clang.patch'::"$_patches/misc/dkms-clang.patch"
)

validpgpkeys=(
    ABAF11C65A2970B130ABE3C479BE3E4300411886 # Linus Torvalds
    647F28654894E3BD457199BE38DBBDC86092693E # Greg Kroah-Hartman
)

b2sums=('8f5f44fa6f7b2a964a3fb14afd10dc0c6cc5ec73eb3b6dba24d35664f7083546b70eff7a3d5a9b3ba3c8b84785518c6df91aff0ed948cd538ff0b3b0484fd613'
        'SKIP'
        'd5752eff0a695850c92224fac67dfa28d7572c1833896e2a8aa9b3dfd0a393c28f8141996cab52b314e59313c3e747af4d279d21b25e32d3221402c47f9c1ee9'
        '390c7b80608e9017f752b18660cc18ad1ec69f0aab41a2edfcfc26621dcccf5c7051c9d233d9bdf1df63d5f1589549ee0ba3a30e43148509d27dafa9102c19ab'
        '964b7c5aa383b530574841ca365a7584b1bde41f5dadb4a029cad61ffd345205aa27be2db46260b314ff40cb0ed33a6260e83e8ae2d7226af6f6b57f057203d0'
        'd9bef12a4d1b3aac695714336f72f4214220745b7aacf54209722050ee7d4a06e65e33db424a01c6ea98f9676197293b5f6841d1ea1c1f8519454d7c5b34580f'
        '4379f5d815485f9b4643edbfd1b5be9cb73bbdb07f600a4ecff2900d6cf88ad7c62d907848cced25e971b79cd870ac705593588ccd3ade586f8eac0b877f0c00'
        'd684dd248a32c12befddfed7355a4b008ceb5ed1b37d992d91654eb1924e513495bfd681dc8e518e145184e021e3aabae8b8a9d2e4444cc12454c08edc5b770e'
        'c7294a689f70b2a44b0c4e9f00c61dbd59dd7063ecbe18655c4e7f12e21ed7c5bb4f5169f5aa8623b1c59de7b2667facb024913ecb9f4c650dabce4e8a7e5452')

export KBUILD_BUILD_USER="${KBUILD_BUILD_USER:-$pkgbase}"
export KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST:-archlinux}"
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"
export KBUILD_BUILD_FLAGS=(
    CC=clang
    LD=ld.lld
    LLVM=1
    LLVM_IAS=1
)

prepare() {

    if [ -d /usr/src/certs-local ]; then
        echo "Rebuilding local signing key..."
        cp -rf /usr/src/certs-local ../
        cd ../certs-local

        echo "Updating kernel config with new key..."
        ./genkeys.py -v --config ../src/config

        cd ../src
    fi

    cd $_srcdir
    echo "Setting version..."
    echo "-$pkgrel" > localversion.10-pkgrel
    echo "${pkgbase#linux}" > localversion.20-pkgname
    if [[ "archlinux" != "$KBUILD_BUILD_HOST" ]]; then
        echo "-$KBUILD_BUILD_HOST" > localversion.20-pkgname
    fi

    local src
    for src in "${source[@]}"; do
        src="${src%%::*}"
        src="${src##*/}"
        src="${src%.zst}"
        [[ $src = *.patch ]] || continue
        echo "Applying patch $src..."
        patch -Nsp1 < "../$src"
    done

    echo "Setting config..."
    cp ../config .config

    ### Configuration
    sh $srcdir/config.sh

    ### CPU optimization
    if [[ "archlinux" != "$KBUILD_BUILD_HOST" ]]; then
        sh $srcdir/auto-cpu-optimization.sh >/dev/null
    fi

    ### AutoFDO
    if [ ! -z KBUILD_BUILD_DEBUG ] || [ ! -z KBUILD_AUTOFDO_PROFILE ]; then
        scripts/config -e AUTOFDO_CLANG
        if [ ! -z KBUILD_AUTOFDO_PROFILE ]; then
            KBUILD_BUILD_FLAGS+=(CLANG_AUTOFDO_PROFILE="${KBUILD_AUTOFDO_PROFILE}")
        fi
    fi

    ### Propeller
    if [ ! -z KBUILD_BUILD_DEBUG ] || [ ! -z KBUILD_PROPELLER_PROFILE_PREFIX ]; then
        scripts/config -e PROPELLER_CLANG
        if [ ! -z KBUILD_AUTOFDO_PROFILE ]; then
            KBUILD_BUILD_FLAGS+=(CLANG_PROPELLER_PROFILE_PREFIX="${KBUILD_PROPELLER_PROFILE_PREFIX}")
        fi
    fi

    ### Modprobed-db
    if [ -f "$HOME/.config/modprobed.db" ]; then
        yes "" | make ${KBUILD_BUILD_FLAGS[*]} LSMOD=$HOME/.config/modprobed.db localmodconfig >/dev/null
    fi

    ### Build host configuration
    if [ -f "$srcdir/config.$KBUILD_BUILD_HOST.sh" ]; then
        sh $srcdir/config.$KBUILD_BUILD_HOST.sh
    fi

    ### Rewrite configuration
    echo "Rewrite configuration..."
    make ${KBUILD_BUILD_FLAGS[*]} prepare
    yes "" | make ${KBUILD_BUILD_FLAGS[*]} config >/dev/null

    ### Prepared version
    make -s kernelrelease > version
    echo "Prepared $pkgbase version $(<version)"
}

build() {
    cd $_srcdir
    make ${KBUILD_BUILD_FLAGS[*]} -j$(nproc) all
    make -C tools/bpf/bpftool vmlinux.h feature-clang-bpf-co-re=1
}

_package() {
    pkgdesc="The $pkgdesc kernel and modules"
    depends=('coreutils' 'kmod' 'initramfs')
    optdepends=('wireless-regdb: to set the correct wireless channels of your country'
                'linux-firmware: firmware images needed for some devices'
                'modprobed-db: Keeps track of EVERY kernel module that has ever been probed - useful for those of us who make localmodconfig'
                'uksmd: userspace KSM helper daemon')
    provides=(KSMBD-MODULE NTSYNC-MODULE UKSMD-BUILTIN VHBA-MODULE VIRTUALBOX-GUEST-MODULES WIREGUARD-MODULE)
    replaces=()

    cd $_srcdir
    local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

    echo "Installing boot image..."
    # systemd expects to find the kernel here to allow hibernation
    # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
    install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

    # Used by mkinitcpio to name the kernel
    echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

    echo "Installing modules..."
    ZSTD_CLEVEL=19 make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
        DEPMOD=/doesnt/exist modules_install  # Suppress depmod

    # remove build links
    rm "$modulesdir"/build
}

_package-headers() {
    pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
    depends=("${pkgbase}" 'clang' 'llvm' 'lld' 'pahole')

    cd $_srcdir
    local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

    echo "Installing build files..."
    install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
        localversion.* version vmlinux tools/bpf/bpftool/vmlinux.h
    install -Dt "$builddir/kernel" -m644 kernel/Makefile
    install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
    cp -t "$builddir" -a scripts

    # required when STACK_VALIDATION is enabled
    install -Dt "$builddir/tools/objtool" tools/objtool/objtool

    # required when DEBUG_INFO_BTF_MODULES is enabled
    if [ -f tools/bpf/resolve_btfids/resolve_btfids ]; then
        install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids
    fi

    echo "Installing headers..."
    cp -t "$builddir" -a include
    cp -t "$builddir/arch/x86" -a arch/x86/include
    install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

    install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
    install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

    # https://bugs.archlinux.org/task/13146
    install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

    # https://bugs.archlinux.org/task/20402
    install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
    install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
    install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

    # https://bugs.archlinux.org/task/71392
    install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

    echo "Installing KConfig files..."
    find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

    echo "Removing unneeded architectures..."
    local arch
    for arch in "$builddir"/arch/*/; do
        [[ $arch = */x86/ ]] && continue
        echo "Removing $(basename "$arch")"
        rm -r "$arch"
    done

    echo "Removing documentation..."
    rm -r "$builddir/Documentation"

    echo "Removing broken symlinks..."
    find -L "$builddir" -type l -printf 'Removing %P\n' -delete

    echo "Removing loose objects..."
    find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

    echo "Stripping build tools..."
    local file
    while read -rd '' file; do
    case "$(file -Sib "$file")" in
        application/x-sharedlib\;*)      # Libraries (.so)
            strip -v $STRIP_SHARED "$file" ;;
        application/x-archive\;*)        # Libraries (.a)
            strip -v $STRIP_STATIC "$file" ;;
        application/x-executable\;*)     # Binaries
            strip -v $STRIP_BINARIES "$file" ;;
        application/x-pie-executable\;*) # Relocatable binaries
            strip -v $STRIP_SHARED "$file" ;;
    esac
    done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

    echo "Stripping vmlinux..."
    strip -v $STRIP_STATIC "$builddir/vmlinux"

    echo "Adding symlink..."
    mkdir -p "$pkgdir/usr/src"
    ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"

    # Out-of-tree module signing
    if [ -d /usr/src/certs-local ]; then
        echo "Local signing certs for out-of-tree modules..."

        certs_local_src="../../certs-local"
        certs_local_dst="${builddir}/certs-local"

        # Certificates
        ${certs_local_src}/install-certs.py $certs_local_dst
    fi
}

_package-dbg() {
    pkgdesc="Non-stripped vmlinux file for the $pkgdesc kernel"
    depends=("${pkgbase}-headers")

    cd $_srcdir
    mkdir -p "$pkgdir/usr/src/debug/${pkgbase}"
    install -Dt "$pkgdir/usr/src/debug/${pkgbase}" -m644 vmlinux
}

for _p in "${pkgname[@]}"; do
    eval "package_$_p() {
        $(declare -f "_package${_p#$pkgbase}")
        _package${_p#$pkgbase}
    }"
done
