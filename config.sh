#!/bin/sh

### CPU
if [ -n "$_MARCH" ]; then
    case "${_MARCH^^}" in
        GENERIC_V[1-4])
            scripts/config \
                -e GENERIC_CPU \
                -d MZEN4 \
                -d X86_NATIVE_CPU \
                --set-val X86_64_VERSION "${_MARCH//GENERIC_V}"
            ;;
        ZEN4)
            scripts/config \
                -d GENERIC_CPU \
                -e MZEN4 \
                -d X86_NATIVE_CPU
            ;;
        NATIVE)
            scripts/config \
                -d GENERIC_CPU \
                -d MZEN4 \
                -e X86_NATIVE_CPU
            ;;
    esac
fi

### CachyOS
scripts/config \
    -e CACHY

### Scheduler
scripts/config  \
    -e SCHED_BORE

### LLVM level
scripts/config \
    -e "LTO_CLANG_${_LTO_CLANG:-FULL}"

### Tick rate
scripts/config \
    -d HZ_300 \
    -e "HZ_${_HZ:-1000}" \
    --set-val HZ "${_HZ:-1000}"

### Governor
scripts/config \
    -d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL \
    -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE

### Tick type
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
    -e PREEMPT_DYNAMIC \
    -e PREEMPT \
    -d PREEMPT_VOLUNTARY \
    -d PREEMPT_LAZY \
    -d PREEMPT_NONE

### Enable O3
scripts/config \
    -d CC_OPTIMIZE_FOR_PERFORMANCE \
    -e CC_OPTIMIZE_FOR_PERFORMANCE_O3

### BBRv3
scripts/config \
    -d DEFAULT_CUBIC \
    -d DEFAULT_FQ_CODEL \
    -e TCP_CONG_BBR \
    -e DEFAULT_BBR \
    --set-str DEFAULT_TCP_CONG bbr \
    -e NET_SCH_FQ \
    -d NET_SCH_FQ_CODEL \
    -e DEFAULT_FQ

### THP
scripts/config \
    -d TRANSPARENT_HUGEPAGE_MADVISE \
    -e TRANSPARENT_HUGEPAGE_ALWAYS

### AutoFDO
scripts/config -d AUTOFDO_CLANG

### Propeller
scripts/config -d PROPELLER_CLANG

### USER_NS
scripts/config \
    -e USER_NS

### Hostname
scripts/config \
    --set-str DEFAULT_HOSTNAME "$KBUILD_BUILD_HOST"

### Framebuffer
scripts/config \
    -e SYSFB_SIMPLEFB

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

### Maximum number of CPUs
if [[ "archlinux" != "$KBUILD_BUILD_HOST" ]]; then
    scripts/config \
        --set-val NR_CPUS $(($(nproc)*2))
fi

### Module signing
if [ -d /usr/src/certs-local ]; then
    scripts/config \
        -e MODULE_SIG_FORCE \
        -d MODULE_ALLOW_MISSING_NAMESPACE_IMPORTS
fi

### ADIOS
scripts/config \
    -e MQ_IOSCHED_DEFAULT_ADIOS

### Cleanup
scripts/config \
    -d ACPI_PRMT \
    -d KMSAN \
    -d ZSWAP \
    -d PSI

exit 0
