
_major=6.10
_minor=3

pkgbase=linux-cachyos
pkgname=("$pkgbase" "$pkgbase-headers")
pkgdesc='Linux BORE + Cachy Sauce scheduler Kernel by CachyOS with other patches and improvements'
pkgver="$_major.$_minor"
pkgrel=2

url="https://github.com/misotolar/linux-cachyos"
license=('GPL2')
arch=(
    x86_64
    x86_64_v3
)

_srcdir="linux-$pkgver"
_kernel="https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x"

_cachyos="a18fcf750a4d3031f872f2c30815513687330d57"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="191926134258604305c668f095e727f7beddbb4d"
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
    tar
    xz
    zstd
)

options=(
    !debug
    !strip
)

source=(
    "$_kernel/linux-$pkgver.tar.xz" "$_kernel/linux-$pkgver.tar.sign"
    "$_cachyos/config" "$_cachyos/auto-cpu-optimization.sh" 'config.sh' 'config.trinity.sh'
    '0101-CACHYOS-cachyos-base-all.patch'::"$_patches/all/0001-cachyos-base-all.patch"
    '0102-CACHYOS-bore-cachy.patch'::"$_patches/sched/0001-bore-cachy.patch"
)

validpgpkeys=(
    ABAF11C65A2970B130ABE3C479BE3E4300411886 # Linus Torvalds
    647F28654894E3BD457199BE38DBBDC86092693E # Greg Kroah-Hartman
)

sha256sums=('fa5f22fd67dd05812d39dca579320c493048e26c4a556048a12385e7ae6fc698'
            'SKIP'
            'dd0db8101a10afe1b1d56539d9b9aace9aebb863f43852275cebb02cee81011c'
            'a91249420d61edb17b8659ab3feca86d24cf3b1c941b14f232c47064fa4f4ce7'
            '42f0f4588f23642c48cf8ddf231af61ae8ea0e3bddd4ad5b05dfb217a7b22cf8'
            '678b3e986971e6696aeab4e85d8d2027f2feba2531993afd3cb1f487f8014d48'
            '46afd18846ced62bfad45acd0532d63491313e0102b2e6c6fe74d7a6e7391f88'
            'e72a452b39c9839b628380cc542f7494ad2492a689486231d354038b3fd5fe9a')

export KBUILD_BUILD_HOST="$(hostname 2>/dev/null || echo -n archlinux)"
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"
export KBUILD_BUILD_FLAGS=(
    CC=clang
    LD=ld.lld
    LLVM=1
    LLVM_IAS=1
)

prepare() {

    ### Arch-SKM
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

    make olddefconfig
    if [ -f "$HOME/.config/modprobed.db" ]; then
        yes "" | make LSMOD=$HOME/.config/modprobed.db localmodconfig >/dev/null
    fi

    ### CPU optimization
    if [[ "archlinux" != "$KBUILD_BUILD_HOST" ]]; then
        sh $srcdir/auto-cpu-optimization.sh >/dev/null
    fi

    ### Default configuration
    sh $srcdir/config.sh >/dev/null

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
    provides=(KSMBD-MODULE UKSMD-BUILTIN VIRTUALBOX-GUEST-MODULES WIREGUARD-MODULE)
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
    depends=('pahole')

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

    if [ -d /usr/src/certs-local ]; then
        echo "Local signing certs for out-of-tree modules..."

        certs_local_src="../../certs-local"
        certs_local_dst="${builddir}/certs-local"

        # Certificates
        ${certs_local_src}/install-certs.py $certs_local_dst
    fi
}

for _p in "${pkgname[@]}"; do
    eval "package_$_p() {
        $(declare -f "_package${_p#$pkgbase}")
        _package${_p#$pkgbase}
    }"
done
