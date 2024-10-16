#!/bin/sh

### CachyOS
scripts/config \
    -e CACHY

### Hostname
scripts/config \
    --set-str DEFAULT_HOSTNAME "$KBUILD_BUILD_HOST"

### RCU priority
scripts/config \
    --set-val RCU_BOOST_DELAY 331

### Scheduler
scripts/config  \
    -e SCHED_CLASS_EXT \
    -e SCHED_BORE

### LLVM level
scripts/config \
    -e LTO \
    -e LTO_CLANG \
    -e ARCH_SUPPORTS_LTO_CLANG \
    -e ARCH_SUPPORTS_LTO_CLANG_THIN \
    -e HAS_LTO_CLANG \
    -e HAVE_GCC_PLUGINS \
    -d LTO_NONE \
    -d LTO_CLANG_FULL \
    -d LTO_CLANG_THIN \
    -e "LTO_CLANG_${_LTO_CLANG:-THIN}"

### Rust
scripts/config \
    -d RUST

### KCFI
scripts/config \
    -d CFI_CLANG

### Ticks
scripts/config \
    -d HZ_100 \
    -d HZ_250 \
    -d HZ_300 \
    -d HZ_500 \
    -d HZ_600 \
    -d HZ_750 \
    -e "HZ_${_HZ:-1000}" \
    --set-val HZ ${_HZ:-1000}

### NUMA
scripts/config \
    -d NUMA \
    -d AMD_NUMA \
    -d X86_64_ACPI_NUMA \
    -d NODES_SPAN_OTHER_NODES \
    -d NUMA_EMU \
    -d USE_PERCPU_NUMA_NODE_ID \
    -d ACPI_NUMA \
    -d ARCH_SUPPORTS_NUMA_BALANCING \
    -d NODES_SHIFT \
    -u NODES_SHIFT \
    -d NEED_MULTIPLE_NODES \
    -d NUMA_BALANCING \
    -d NUMA_BALANCING_DEFAULT_ENABLED

### PSI
scripts/config \
    -d PSI

### Maximum number of CPUs
if [[ "archlinux" != "$KBUILD_BUILD_HOST" ]]; then
    scripts/config \
        --set-val NR_CPUS $(($(nproc)*2))
fi

### TCP congestion control
scripts/config \
    -d TCP_CONG_BIC \
    -d TCP_CONG_CUBIC \
    -d TCP_CONG_WESTWOOD \
    -d TCP_CONG_HTCP \
    -d TCP_CONG_HSTCP \
    -d TCP_CONG_HYBLA \
    -d TCP_CONG_VEGAS \
    -d TCP_CONG_NV \
    -d TCP_CONG_SCALABLE \
    -d TCP_CONG_LP \
    -d TCP_CONG_VENO \
    -d TCP_CONG_YEAH \
    -d TCP_CONG_ILLINOIS \
    -d TCP_CONG_DCTCP \
    -d TCP_CONG_CDG \
    -d TCP_CONG_BBR2 \
    -e TCP_CONG_BBR \
    -d DEFAULT_BBR2 \
    -e DEFAULT_BBR \
    --set-str DEFAULT_TCP_CONG bbr

### Tickrate
scripts/config \
    -d HZ_PERIODIC \
    -d NO_HZ_IDLE \
    -d CONTEXT_TRACKING_FORCE \
    -e NO_HZ_FULL_NODEF \
    -e NO_HZ_FULL \
    -e NO_HZ \
    -e NO_HZ_COMMON \
    -e CONTEXT_TRACKING

### Preempt
scripts/config \
    -e PREEMPT_BUILD \
    -d PREEMPT_NONE \
    -d PREEMPT_VOLUNTARY \
    -e PREEMPT \
    -e PREEMPT_COUNT \
    -e PREEMPTION \
    -e PREEMPT_DYNAMIC

### ZSTD
scripts/config \
    --set-val ZSTD_COMPRESSION_LEVEL 3 \
    --set-val MODULE_COMPRESS_ZSTD_LEVEL 3

### Hardening
scripts/config \
    -d CONFIG_RANDSTRUCT_FULL \
    -d CONFIG_RANDSTRUCT_PERFORMANCE \
    -e CONFIG_RANDSTRUCT_NONE

### Debug
scripts/config \
    -d SLUB_DEBUG \
    -d PM_DEBUG \
    -d PM_ADVANCED_DEBUG \
    -d PM_SLEEP_DEBUG \
    -d ACPI_DEBUG \
    -d SCHED_DEBUG \
    -d LATENCYTOP \
    -d DEBUG_PREEMPT \
    -d KMSAN

### Framebuffer
scripts/config \
    -e SYSFB_SIMPLEFB

### Cleanup
scripts/config \
    -d ACPI_PRMT \
    -d HYPERVISOR_GUEST

### Arch-SKM
if [ -d /usr/src/certs-local ]; then
    scripts/config \
        -e MODULE_SIG_FORCE \
        -d MODULE_ALLOW_MISSING_NAMESPACE_IMPORTS
fi
