#!/bin/sh

EXTRA_FIRMWARE_DIR="$(mktemp -d)";
EXTRA_FIRMWARE_STR=""
EXTRA_FIRMWARE=(
    i915/kbl_dmc_ver1_04.bin
    i915/kbl_guc_70.1.1.bin
    i915/kbl_huc_4.0.0.bin
    intel/ibt-12-16.sfi
    intel/ibt-12-16.ddc
    rtl_nic/rtl8153a-3.fw
    iwlwifi-8265-36.ucode
    regulatory.db.p7s
    regulatory.db
)

for BLOB in "${EXTRA_FIRMWARE[@]}"; do
    EXTRA_FIRMWARE_STR="${EXTRA_FIRMWARE_STR} ${BLOB}"
    mkdir -p "${EXTRA_FIRMWARE_DIR}/$(dirname ${BLOB})"
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

# Standalone
scripts/config \
    -d BOOTTIME_TRACING \
    -d BOOT_CONFIG \
    -d BLK_DEV_INITRD

# Firmware
scripts/config --set-str EXTRA_FIRMWARE "${EXTRA_FIRMWARE_STR}"
scripts/config --set-str EXTRA_FIRMWARE_DIR "${EXTRA_FIRMWARE_DIR}"

### Governor
scripts/config \
    -d CPU_FREQ_GOV_USERSPACE \
    -d CPU_FREQ_GOV_ONDEMAND \
    -d CPU_FREQ_GOV_CONSERVATIVE \
    -d CPU_FREQ_GOV_SCHEDUTIL \
    -d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL \
    -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE

# ACPI
scripts/config \
    -e THINKPAD_ACPI \
    -e ACPI_PROCESSOR_AGGREGATOR \
    -e INT340X_THERMAL

# Input
scripts/config \
    -e KEYBOARD_ATKBD \
    -e MOUSE_PS2 \
    -e INPUT_MOUSEDEV \
    -e INPUT_JOYDEV \
    -e SERIO_RAW \
    -e RMI4_CORE \
    -e RMI4_SMB

# HID
scripts/config \
    -e CONFIG_MAC_EMUMOUSEBTN

# Graphics
scripts/config \
    -e DRM_I915

# Storage
scripts/config \
    -e BLK_DEV_DM \
    -e DM_INIT \
    -e BLK_DEV_LOOP \
    -e BLK_DEV_NVME \
    -e EXT4_FS \
    -e VFAT_FS \
    -e FUSE_FS \
    -e NLS_ISO8859_1 \
    -e NLS_UTF8

# USB
scripts/config \
    -e USB_UAS \
    -e USB_STORAGE \
    -e USB_ROLE_SWITCH \
    -e USB_ROLES_INTEL_XHCI \
    -e USB_XHCI_PCI_RENESAS \
    -e TYPEC \
    -e TYPEC_UCSI \
    -e TYPEC_DP_ALTMODE \
    -e UCSI_ACPI

# I2C
scripts/config \
    -e I2C_I801

# Network
scripts/config \
    -e E1000E \
    -e RFKILL \
    -e CFG80211 \
    -e MAC80211 \
    -e IWLWIFI \
    -e IWLMVM

# Bluetooth
scripts/config \
    -e BT \
    -e BT_BNEP \
    -e BT_RFCOMM \
    -e BT_HCIBTUSB

# Media
scripts/config \
    -e MEDIA_SUPPORT \
    -e USB_VIDEO_CLASS

# Sound
scripts/config \
    -e SOUND \
    -e SND \
    -e SND_HRTIMER \
    -e SND_SEQUENCER \
    -e SND_SEQ_DUMMY \
    -e SND_HDA_INTEL \
    -e SND_HDA_CODEC_HDMI \
    -e SND_HDA_CODEC_REALTEK \
    -e SND_HDA_CODEC_GENERIC \
    -e SND_SOC \
    -e SND_SOC_HDA \
    -e SND_SOC_INTEL_AVS

# Thermal
scripts/config \
    -e INTEL_POWERCLAMP \
    -e X86_PKG_TEMP_THERMAL \
    -e INTEL_PCH_THERMAL \
    -e INTEL_TCC_COOLING

# KVM
scripts/config \
    -e KVM \
    -e KVM_INTEL

# Platform
scripts/config \
    -e INTEL_VSEC \
    -e INTEL_PMC_CORE \
    -e INTEL_PMT_CLASS \
    -e INTEL_PMT_TELEMETRY \
    -e INTEL_UNCORE_FREQ_CONTROL \
    -e WMI_BMOF \
    -e INTEL_WMI_THUNDERBOLT \
    -e THINKPAD_LMI

# Crypto
scripts/config \
    -e CRYPTO_SIMD \
    -e CRYPTO_USER \
    -e CRYPTO_USER_API_HASH \
    -e CRYPTO_USER_API_SKCIPHER \
    -e CRYPTO_CRC32_PCLMUL \
    -e CRYPTO_CRCT10DIF_PCLMUL \
    -e CRYPTO_POLYVAL \
    -e CRYPTO_POLYVAL_CLMUL_NI \
    -e CRYPTO_CRC32C_INTEL \
    -e CRYPTO_AES_NI_INTEL \
    -e CRYPTO_GHASH_CLMUL_NI_INTEL \
    -e CRYPTO_SHA1_SSSE3 \
    -e CRYPTO_SHA256_SSSE3 \
    -e CRYPTO_SHA512_SSSE3

# Misc
scripts/config \
    -e INTEL_MEI \
    -e INTEL_MEI_ME \
    -e INTEL_MEI_WDT \
    -e INTEL_MEI_HDCP \
    -e INTEL_MEI_PXP \
    -e INTEL_RAPL \
    -e PERF_EVENTS_INTEL_CSTATE \
    -e PERF_EVENTS_INTEL_RAPL \
    -e PERF_EVENTS_INTEL_UNCORE \
    -e SENSORS_CORETEMP \
    -e PTP_1588_CLOCK \
    -e EEPROM_EE1004

exit 0
