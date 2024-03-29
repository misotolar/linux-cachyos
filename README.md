# CachyOS Kernel Arch Linux package
[![Build Status](https://drone02.sotolar.net/api/badges/misotolar/linux-cachyos/status.svg)](https://drone02.sotolar.net/misotolar/linux-cachyos)

Improved [CachyOS Kernel](https://github.com/cachyos/linux-cachyos) with custom config:

- LLVM/LTO build
- [TSC direct sync](https://lore.kernel.org/all/84f991e0-4d14-7ea9-7553-9f688df9cd49@collabora.com/T/#m156fc8ddb3f69691fefedb7bba49a280fe97938e) implementation
- [BORE](https://github.com/firelzrd/bore-scheduler) scheduler 
- DKMS kernel module signing with [Arch-SKM](https://aur.archlinux.org/packages/arch-sign-modules)

```
[linux-cachyos]
SigLevel = Never
Server = https://archlinux.sotolar.net/linux-cachyos
```
