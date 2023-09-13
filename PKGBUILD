
_major=6.5
_minor=3

pkgbase=linux-cachyos
pkgname=("$pkgbase" "$pkgbase-headers")
pkgdesc='Linux EEVDF scheduler Kernel by CachyOS with other patches and improvements'
pkgver="$_major.$_minor"
pkgrel=1

_srcdir="linux-$pkgver"
_kernel="https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x"

_cachyos="6f6390a35b8ce59767b2a65f01675694a7835860"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="9acad4cb097cd06c7c826a895f87b54b31d08fba"
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
        '0102-CACHYOS-EEVDF-cachy.patch'::"$_patches/sched/0001-EEVDF-cachy.patch"
        '0103-CACHYOS-bore-eevdf.patch'::"$_patches/sched/0001-bore-eevdf.patch"
        '0104-CACHYOS-lrng.patch'::"$_patches/misc/0001-lrng.patch")

sha256sums=('4cac13f7b17bd8dcf9032ad68f9123ab5313d698c9f59416043165150763eb4f'
            'SKIP'
            'eec1f88ae64c6a972c17b177ef2c9d150a13ca054c338a172829519fabceb16d'
            '41c34759ed248175e905c57a25e2b0ed09b11d054fe1a8783d37459f34984106'
            '11cd77e1eb319eff7676e6ae297786bd7a0572160c9dc36e48d5bc91c9547c54'
            '65c93f050b25c8f95d99501067bff676d8ef8148c78420bb2b71a7fbb7ee19af'
            '980b2108bca4d97acbb8bd962695acac012c8846294486104e25994f059b3594'
            'd66f2487a84875aea6dd81038a2b806ffb8af2f4c7e4366df0db44c1e3c17b5d'
            'a6c087a8b1efe889663c48a94ad763a2cf20aa587c40b4cc3d2f89c9bce786c0'
            'ce17045b4d29519d20920ae7ef33f82757e00b1e189ecbda6ab63782f1318759'
            'd27a2acec2e65df2226d2025ab255a74acd01ed2162e00907362464e5a2636fc'
            '3f51da3f1ed5a0d115e69047ef9fd1cfb36adf48d0e6d812fbf449b61db5d373'
            'a4bfbba3b282246c137c6d2653b16e7082af177bcddfe522f7a170d076ed9d79'
            '86d9d0f44cc4273eaf35b136b70027583c9df64c1d27e0c72f5647654da7638d'
            '3c1fe46f842d141087b59c6838ec35970be7cc3a2785839e72d32c9971089876'
            '18d1a9894e313a013b14436e8df748c318248b75151676811c25d3317f5207d4')

validpgpkeys=('ABAF11C65A2970B130ABE3C479BE3E4300411886'   # Linus Torvalds
              '647F28654894E3BD457199BE38DBBDC86092693E')  # Greg Kroah-Hartman

export KBUILD_BUILD_HOST="$(hostname 2>/dev/null || echo -n archlinux)"
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
