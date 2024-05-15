# CachyOS Kernel Arch Linux package
[![status-badge](https://build02.sotolar.net/api/badges/5/status.svg)](https://build02.sotolar.net/repos/5)

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
