
_major=6.3
_minor=6

pkgbase=linux-cachyos
pkgname=("$pkgbase" "$pkgbase-headers")
pkgdesc='Linux EEVDF scheduler Kernel by CachyOS with other patches and improvements'
pkgver="$_major.$_minor"
pkgrel=1

_srcdir="linux-$pkgver"
_kernel="https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x"

_cachyos="8180543ca95e9353464f90c5f9975add33f5fe01"
_cachyos="https://raw.githubusercontent.com/cachyos/linux-cachyos/$_cachyos/linux-cachyos"
_patches="229660f0c4cf6efa861c5a58718376453492c9c2"
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
        '0104-CACHYOS-lrng.patch'::"$_patches/misc/0001-lrng.patch")

sha256sums=('7a6a1f0dfa0bf7f45f9d4a7b409315cf32267850adab4db033a17de0320a24ef'
            'SKIP'
            'd7c20a38071edb47464042d63e8ef555cb5906916773bbe8f992bfe4c0a5748e'
            '41c34759ed248175e905c57a25e2b0ed09b11d054fe1a8783d37459f34984106'
            '84a343a03454deedf0d08ddfd69c0a8ffe666cba1e28108d795bbb7281298cba'
            '93d8ed2d12194510f91a92afd3d6a99e0a11240f60fbcfa589e860a06eb989ac'
            '54f77dca3802a9e1036d20cacbc3356823f038b63b6792225a51cc4b8630fa34'
            'd65bd6c210896610b54abfad15b86756382d3a1eb48835b6a2e16ea5ea541863'
            '70472f2ffc33a40796abe7eca9ba5c534fe2b6c035bad1dd13cb6bcd7acd58ab'
            'f544db22d1ddd9dd482ba552309775671ffb3c712cd43a9fae6fc0152868cc94'
            'd7e2500fe861c78e3087431f2964f4e79eb2cd3588aadff746f9a9e9b5913804'
            '3f51da3f1ed5a0d115e69047ef9fd1cfb36adf48d0e6d812fbf449b61db5d373'
            '307414d755f30d3e4c2ded0eeef658dbf503177002ab8c5d06812ba6e0c97c42'
            '9d1baeed3f2e8d53e810c58b3ca6374e0683f72fc0365fca11d350aef550239e'
            'b7af072d612c6607728b093b1521eea50c2eff825f3763c3f49139311e963791'
            '2fff325cf71ecc86dfdd2279460f03bfad42e39e2548ad1009326c0fccaa30e9')

validpgpkeys=('ABAF11C65A2970B130ABE3C479BE3E4300411886'   # Linus Torvalds
              '647F28654894E3BD457199BE38DBBDC86092693E'   # Greg Kroah-Hartman
              'A2FF3A36AAA56654109064AB19802F8B0D70FC30'   # Jan Alexander Steffens (heftig)
              'C5ADB4F3FEBBCE27A3E54D7D9AE4078033F8024D')  # Steven Barrett <steven@liquorix.net>

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
