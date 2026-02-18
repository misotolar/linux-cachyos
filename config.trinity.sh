#!/bin/sh

EXTRA_FIRMWARE_DIR="$(mktemp -d)";
EXTRA_FIRMWARE_STR=""
EXTRA_FIRMWARE=(
    i915/kbl_dmc_ver1_04.bin
    i915/kbl_guc_70.1.1.bin
    i915/kbl_huc_4.0.0.bin
    iwlwifi-9000-pu-b0-jf-b0-46.ucode
    intel/ibt-17-16-1.sfi
    intel/ibt-17-16-1.ddc
    intel-ucode/06-9e-0a
    regulatory.db.p7s
    regulatory.db
)

for BLOB in "${EXTRA_FIRMWARE[@]}"; do
    EXTRA_FIRMWARE_STR="${EXTRA_FIRMWARE_STR} ${BLOB}"
    mkdir -p "${EXTRA_FIRMWARE_DIR}/$(dirname "${BLOB}")"
    if [ -f "/lib/firmware/${BLOB}" ]; then
        cp -v "/lib/firmware/${BLOB}" "${EXTRA_FIRMWARE_DIR}/${BLOB}"
    elif [ -f "/lib/firmware/${BLOB}.xz" ]; then
        cp -v "/lib/firmware/${BLOB}.xz" "${EXTRA_FIRMWARE_DIR}/${BLOB}.xz"
        xz -d "${EXTRA_FIRMWARE_DIR}/${BLOB}.xz"
    elif [ -f "/lib/firmware/${BLOB}.zst" ]; then
        cp -v "/lib/firmware/${BLOB}.zst" "${EXTRA_FIRMWARE_DIR}/${BLOB}.zst"
        zstd -qd "${EXTRA_FIRMWARE_DIR}/${BLOB}.zst"
    fi
done

# General
scripts/config \
    -d BOOT_CONFIG \
    -d BLK_DEV_INITRD

# Processor
scripts/config \
    -d HYPERVISOR_GUEST \
    -d GENERIC_CPU \
    -d MZEN4 \
    -e X86_NATIVE_CPU \
    -e PERF_EVENTS_INTEL_UNCORE \
    -e PERF_EVENTS_INTEL_RAPL \
    -e PERF_EVENTS_INTEL_CSTATE

# Power
scripts/config \
    -e ACPI_PROCESSOR_AGGREGATOR

# Virtualization
scripts/config \
    -e KVM \
    -e KVM_INTEL

# Block layer
scripts/config \
    -d MQ_IOSCHED_DEADLINE \
    -d MQ_IOSCHED_KYBER \
    -e MQ_IOSCHED_ADIOS

# Networking
scripts/config \
    -e BT \
    -e BT_BNEP \
    -e BT_HCIBTUSB \
    -e CFG80211 \
    -e MAC80211 \
    -e RFKILL

# Firmware
scripts/config \
    --set-str EXTRA_FIRMWARE "${EXTRA_FIRMWARE_STR}" \
    --set-str EXTRA_FIRMWARE_DIR "${EXTRA_FIRMWARE_DIR}"

# MTD
scripts/config \
    -e MTD \
    -e MTD_SPI_NOR

# Block
scripts/config \
    -d ZRAM_BACKEND_LZ4HC \
    -d ZRAM_BACKEND_DEFLATE \
    -d ZRAM_BACKEND_842 \
    -d ZRAM_BACKEND_LZO \
    -e ZRAM \
    -e BLK_DEV_LOOP

# NVME
scripts/config \
    -e BLK_DEV_NVME

# Misc
scripts/config \
    -e NTSYNC \
    -e EEPROM_EE1004 \
    -e INTEL_MEI \
    -e INTEL_MEI_ME \
    -e INTEL_MEI_HDCP \
    -e INTEL_MEI_PXP \
    -e MISC_RTSX_PCI

# RAID/LVM
scripts/config \
    -e BLK_DEV_DM \
    -e DM_INIT

# Macintosh
scripts/config \
    -e CONFIG_MAC_EMUMOUSEBTN

# Network
scripts/config \
    -e E1000E \
    -e IWLWIFI \
    -e IWLMVM

# Input
scripts/config \
    -e INPUT_MOUSEDEV \
    -e INPUT_JOYDEV \
    -e INPUT_UINPUT \
    -e KEYBOARD_ATKBD \
    -e MOUSE_PS2 \
    -e MOUSE_ELAN_I2C \
    -e SERIO_RAW

# Character
scripts/config \
    -e SERIAL_8250_DW

# I2C
scripts/config \
    -e I2C_CHARDEV \
    -e I2C_I801

# SPI
scripts/config \
    -e SPI_INTEL_PCI

# PTP
scripts/config \
    -e PTP_1588_CLOCK

# Monitoring
scripts/config \
    -e SENSORS_CORETEMP

# Thermal
scripts/config \
    -e INTEL_POWERCLAMP \
    -e X86_PKG_TEMP_THERMAL \
    -e INT340X_THERMAL \
    -e INTEL_PCH_THERMAL \
    -e INTEL_TCC_COOLING

# Watchdog
scripts/config \
    -e INTEL_MEI_WDT

# Multifunction
scripts/config \
    -e MFD_INTEL_LPSS_PCI

# Multimedia
scripts/config \
    -e MEDIA_SUPPORT \
    -e USB_VIDEO_CLASS

# Graphics
scripts/config \
    -e DRM_I915

# Sound
scripts/config \
    -e SOUND \
    -e SND \
    -e SND_HDA_INTEL \
    -e SND_HDA_CODEC_REALTEK \
    -e SND_HDA_CODEC_HDMI \
    -e SND_SOC \
    -e SND_SOC_INTEL_AVS \
    -e SND_SOC_SOF_PCI \
    -e SND_SOC_SOF_CANNONLAKE

# USB
scripts/config \
    -e TYPEC \
    -e TYPEC_UCSI \
    -e UCSI_ACPI \
    -e TYPEC_DP_ALTMODE \
    -e USB_ROLE_SWITCH

# SD/MMC
scripts/config \
    -e MMC \
    -e MMC_REALTEK_PCI

# DMA
scripts/config \
    -e INTEL_IDMA64

# Platform
scripts/config \
    -e WMI_BMOF \
    -e THINKPAD_ACPI \
    -e THINKPAD_LMI \
    -e INTEL_PMC_CORE \
    -e INTEL_PMT_TELEMETRY \
    -e INTEL_WMI_THUNDERBOLT \
    -e INTEL_UNCORE_FREQ_CONTROL \
    -e INTEL_VSEC

# Powercap
scripts/config \
    -e INTEL_RAPL

# Pinctrl
scripts/config \
    -e PINCTRL_CANNONLAKE

# Filesystems
scripts/config \
    -e VFAT_FS

# Crypto
scripts/config \
    -e CRYPTO_USER \
    -e CRYPTO_USER_API_HASH \
    -e CRYPTO_USER_API_SKCIPHER \
    -e CRYPTO_LZ4 \
    -e CRYPTO_AES_NI_INTEL \
    -e CRYPTO_POLYVAL_CLMUL_NI \
    -e CRYPTO_SHA1_SSSE3 \
    -e CRYPTO_SHA512_SSSE3 \
    -e CRYPTO_GHASH_CLMUL_NI_INTEL

# Hacking
scripts/config \
    -d BOOTTIME_TRACING

exit 0
