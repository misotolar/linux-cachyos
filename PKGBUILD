
_major=6.18
_minor=9

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

_cachyos="1a3b979f284e343eb56a73c45c0ad8d3bf11ecde"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="fd1f0c2b7020e735de3981dcceada77fe1305580"
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
    "$_kernel/$_srcdir.tar.xz"
    "$_kernel/$_srcdir.tar.sign"
    "$_cachyos/config" 'config.sh' 'config.trinity.sh'
    '0101-CACHYOS-cachyos-base-all.patch'::"$_patches/all/0001-cachyos-base-all.patch"
    '0102-CACHYOS-bore-cachy.patch'::"$_patches/sched/0001-bore-cachy.patch"
    '0103-CACHYOS-dkms-clang.patch'::"$_patches/misc/dkms-clang.patch"
)

validpgpkeys=(
    ABAF11C65A2970B130ABE3C479BE3E4300411886 # Linus Torvalds
    647F28654894E3BD457199BE38DBBDC86092693E # Greg Kroah-Hartman
)

b2sums=('9aed902e41583597cb7595efe77504630a621993d20f89365a93cf2ea4d9790a6361d93cbb7fd7603881a4f82b76394b7e12fb4e4a88c9fedb2d63d64a9d49d3'
        'SKIP'
        '81fafd3adcaf3b690d8d4791693e68c7ae921d103ebfd70e8d0ae15cd05ecde5e6672ae43c3a7875686d883c1f5b82d2c8b37b40aee8dcb0563913f9dd6469b6'
        'e20d1013d5870a2dfd6ab30aa5c0978ddf052570f518b7a8c4cad8e2a1a9c0f18e4eb033091baf017a751e196dc86286d28c19252aa2f4b078d54915da424d5d'
        'd3db1c54c1e3e530bff681d0bf806e05c2dcef8387857e15c92d9f8fdd755fed3c9ca135330e5db0bcba0fbdc999885292477ed43c689b190d4f410583511683'
        'e8c3431da432a8cd84f4629bacde651ee820782c988671f7554d3cc15b8a3af8e19d244c78e430d03f7a03374030f8c660d7ddcc9a19a7f739b58cd72a3e6477'
        '01153ff4c27e4ba3b47fbbc99b07b540fabf769b6d9a02c8b9f3a691c2f5865d03389138b54323efc1eb36341e60752e40005a3f8236368895c3e475bcac1d4b'
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
                'scx-scheds: to use sched-ext schedulers')
    provides=(ADIOS-MODULE KSMBD-MODULE NTSYNC-MODULE UKSMD-BUILTIN VHBA-MODULE VIRTUALBOX-GUEST-MODULES V4L2LOOPBACK-MODULE WIREGUARD-MODULE)
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
    ZSTD_CLEVEL=-1 make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
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
    ln -srt "$builddir" "$builddir/scripts/gdb/vmlinux-gdb.py"

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

    # Install .rmeta files if they exist
    if compgen -G "rust/*.rmeta" 1>/dev/null; then
        install -Dt "$builddir/rust" -m644 rust/*.rmeta
    fi

    # Install .so files if they exist
    if compgen -G "rust/*.so" 1>/dev/null; then
        install -Dt "$builddir/rust" rust/*.so
    fi

    echo "Installing unstripped VDSO..."
    make INSTALL_MOD_PATH="$pkgdir/usr" vdso_install \
      link=  # Suppress build-id symlinks

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
