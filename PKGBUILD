
_major=6.4
_minor=9

pkgbase=linux-cachyos
pkgname=("$pkgbase" "$pkgbase-headers")
pkgdesc='Linux EEVDF scheduler Kernel by CachyOS with other patches and improvements'
pkgver="$_major.$_minor"
pkgrel=1

_srcdir="linux-$pkgver"
_kernel="https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x"

_cachyos="e00a3d85f2ad42ebb658191d2c8112267ff30575"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="a4e3ee6c55ffec5f6a071df2bdb73b88b921ac28"
_patches="https://raw.githubusercontent.com/cachyos/kernel-patches/$_patches/$_major"

arch=('x86_64' 'x86_64_v3')
url="https://github.com/misotolar/linux-cachyos"
license=('GPL2')

makedepends=('bc' 'clang' 'cpio' 'libelf' 'lld' 'llvm' 'pahole' 'perl' 'python' 'tar' 'xz' 'zstd')
options=('!strip')

source=("$_kernel/linux-$pkgver.tar.xz" "$_kernel/linux-$pkgver.tar.sign"
        "$_cachyos/config" "$_cachyos/auto-cpu-optimization.sh" 'config.sh' 'config.trinity.sh'
        '0001-x86-implement-tsc-directsync-for-systems-without-IA3.patch'
        '0002-x86-touch-clocksource-watchdog-after-syncing-TSCs.patch'
        '0003-x86-save-restore-TSC-counter-value-during-sleep-wake.patch'
        '0004-x86-only-restore-TSC-if-we-have-IA32_TSC_ADJUST-or-d.patch'
        '0005-x86-don-t-check-for-random-warps-if-using-direct-syn.patch'
        '0006-x86-disable-tsc-watchdog-if-using-direct-sync.patch'
        '0101-CACHYOS-cachyos-base-all.patch'::"$_patches/all/0001-cachyos-base-all.patch"
        '0102-CACHYOS-EEVDF.patch'::"$_patches/sched/0001-EEVDF.patch"
        '0103-CACHYOS-bore-eevdf.patch'::"$_patches/sched/0001-bore-eevdf.patch"
        '0104-CACHYOS-lrng.patch'::"$_patches/misc/0001-lrng.patch"
        '0105-8a9b1f65817e94281ed5922ccee877ab99add71e.patch'::"https://github.com/ClangBuiltLinux/linux/commit/8a9b1f65817e94281ed5922ccee877ab99add71e.patch"
        '0106-150c42407f87463c27a2459e06845965291d9973.patch'::"https://github.com/ClangBuiltLinux/linux/commit/150c42407f87463c27a2459e06845965291d9973.patch")

sha256sums=('b8b8a29852b999f337c4e93eff6c91fb7fd2d49a6614cbcbeb6fa171ba55cc9f'
            'SKIP'
            '17472f100b4f4c2b8c67a18a1f7f2d925224489a3da12c3a0962b9e602334069'
            '41c34759ed248175e905c57a25e2b0ed09b11d054fe1a8783d37459f34984106'
            '073f531863e83939d63eb1240b29dd71a6cd85347093a165b733587342ab1948'
            '65c93f050b25c8f95d99501067bff676d8ef8148c78420bb2b71a7fbb7ee19af'
            '57baf245a75f9fd2686d701a496fa7ac095ff0cd27efea5e82987c3d763a9a91'
            'a31b916982a0def9d167809d7a8044fc5d5441d013b9908449796ea46e37c952'
            'aae77518f548d6ea4198a2921c9b708fdbb39f778266c9c1e08c831215c121f5'
            'a8ffaf6a6438be5ea4d76a9cdf918c108eab17f2349363f2baef3dee8885f9ee'
            '330c5c021b98486d774505cbb6def4084d6b040a66e9bc6e45e72f48a0fa670c'
            '3f51da3f1ed5a0d115e69047ef9fd1cfb36adf48d0e6d812fbf449b61db5d373'
            '0e5249f950bfcbf248be23cd2be222072a37b493977758d36df36e737446fe23'
            '33d74a741d592641e9999e3c87764233a2583554b11a3665c8fcb7e17a537fff'
            'b1c2ba2fa47538b5421591147eead59890dfa0d2f88574613b7c693ab1551e16'
            '0fc0847f207be6a52b7d853eb5944447253c5f331cc1e762edf06120b34dfb82'
            'f2d20461beb640ebedf029653c1ed204d675775940f8ebfb7e39406101a03aeb'
            'ece8084dafbe17c1355cdf5434946d1a04f0c8979f11e16e5db2ef14ac7dd726')

validpgpkeys=('ABAF11C65A2970B130ABE3C479BE3E4300411886'   # Linus Torvalds
              '647F28654894E3BD457199BE38DBBDC86092693E')  # Greg Kroah-Hartman

export KBUILD_BUILD_HOST="$(hostname 2>/dev/null || echo -n archlinux)"
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"
export KBUILD_BUILD_FLAGS=(
    CC=clang
    LD=ld.lld
    LLVM=1
    LLVM_IAS=1
)

_make() {
  test -s version
  make KERNELRELEASE="$(<version)" ${KBUILD_BUILD_FLAGS[*]} "$@"
}

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

    make ${KBUILD_BUILD_FLAGS[*]} defconfig
    make ${KBUILD_BUILD_FLAGS[*]} -s kernelrelease > version
    make ${KBUILD_BUILD_FLAGS[*]} mrproper

    local src
    for src in "${source[@]}"; do
        src="${src%%::*}"
        src="${src##*/}"
        [[ $src = *.patch ]] || continue
        echo "Applying patch $src..."
        patch -Nsp1 < "../$src"
    done

    echo "Setting config..."
    cp ../config .config

    _make olddefconfig
    if [ -f "$HOME/.config/modprobed.db" ]; then
        yes "" | _make LSMOD=$HOME/.config/modprobed.db localmodconfig >/dev/null
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

    echo "Prepared $pkgbase version $(<version)"
}

build() {
    cd $_srcdir
    _make -j$(nproc) all
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
    install -Dm644 "$(_make -s image_name)" "$modulesdir/vmlinuz"

    # Used by mkinitcpio to name the kernel
    echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

    echo "Installing modules..."
    _make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 modules_install

    # remove build and source links
    rm "$modulesdir"/{source,build}
}

_package-headers() {
    pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
    depends=('pahole')

    cd $_srcdir
    local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

    echo "Installing build files..."
    install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map localversion.* version vmlinux
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
