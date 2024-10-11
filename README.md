# CachyOS Kernel Arch Linux package
[![status-badge](https://build02.sotolar.net/api/badges/5/status.svg)](https://build02.sotolar.net/repos/5)

Improved [CachyOS Kernel](https://github.com/cachyos/linux-cachyos) with custom config:

- LLVM/LTO build
- SCHED-EXT with [BORE](https://github.com/firelzrd/bore-scheduler) scheduler
- DKMS kernel module signing with [Arch-SKM](https://aur.archlinux.org/packages/arch-sign-modules)

```
[linux-cachyos]
SigLevel = Never
Server = https://archlinux.sotolar.net/linux-cachyos
```
