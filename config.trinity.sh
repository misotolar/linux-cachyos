#!/bin/sh

EXTRA_FIRMWARE_DIR="$(mktemp -d)";
EXTRA_FIRMWARE_STR=""
EXTRA_FIRMWARE=(
    amdgpu/picasso_gpu_info.bin
    amdgpu/picasso_asd.bin
    amdgpu/picasso_ta.bin
    amdgpu/picasso_pfp.bin
    amdgpu/picasso_me.bin
    amdgpu/picasso_ce.bin
    amdgpu/picasso_rlc.bin
    amdgpu/picasso_mec.bin
    amdgpu/picasso_mec2.bin
    amdgpu/picasso_sdma.bin
    amdgpu/picasso_vcn.bin
    amdgpu/raven_dmcu.bin
    intel/ibt-20-1-3.sfi
    iwlwifi-cc-a0-74.ucode
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

# Input
scripts/config \
    -e KEYBOARD_ATKBD \
    -e INPUT_JOYDEV \
    -e INPUT_MOUSEDEV \
    -e SERIO_RAW

# HID
scripts/config \
    -e I2C_HID \
    -e I2C_HID_ACPI \
    -e HID_MULTITOUCH \
    -e CONFIG_MAC_EMUMOUSEBTN

# Graphics
scripts/config \
    -e DRM_AMDGPU

# Storage
scripts/config \
    -e BLK_DEV_DM \
    -e BLK_DEV_LOOP \
    -e BLK_DEV_NVME \
    -e EXT4_FS \
    -e VFAT_FS \
    -e FUSE_FS \
    -e NLS_ISO8859_1 \
    -e NLS_UTF8

# Network
scripts/config \
    -e RFKILL \
    -e CFG80211 \
    -e MAC80211 \
    -e IWLWIFI \
    -e IWLDVM \
    -e IWLMVM \
    -e BT \
    -e BT_RFCOMM \
    -e BT_BNEP \
    -e BT_HCIBTUSB

# KVM
scripts/config \
    -e KVM \
    -e KVM_AMD

# Platform
scripts/config \
    -e WMI_BMOF \
    -e IDEAPAD_LAPTOP

# Crypto
scripts/config \
    -e CRYPTO_LZ4 \
    -e CRYPTO_DEV_CCP_DD \
    -e CRYPTO_AES_NI_INTEL \
    -e CRYPTO_USER \
    -e CRYPTO_USER_API_HASH \
    -e CRYPTO_USER_API_SKCIPHER \
    -e CRYPTO_POLYVAL_CLMUL_NI \
    -e CRYPTO_SHA512_SSSE3 \
    -e CRYPTO_GHASH_CLMUL_NI_INTEL \
    -e CRYPTO_CRC32C_INTEL \
    -e CRYPTO_CRC32_PCLMUL \
    -e CRYPTO_CRCT10DIF_PCLMUL

# Sound
scripts/config \
    -e SOUND \
    -e SND \
    -e SND_HRTIMER \
    -e SND_SEQUENCER \
    -e SND_SEQ_DUMMY \
    -e SND_HDA_INTEL \
    -e SND_HDA_CODEC_REALTEK \
    -e SND_HDA_CODEC_HDMI \
    -e SND_SOC \
    -e SND_SOC_AMD_RENOIR \
    -e SND_SOC_AMD_ACP_COMMON \
    -e SND_SOC_AMD_ACP_PCI \
    -e SND_SOC_AMD_PS \
    -e SND_SOC_SOF_PCI \
    -e SND_SOC_SOF_AMD_TOPLEVEL \
    -e SND_SOC_SOF_AMD_RENOIR \
    -e SND_SOC_SOF_AMD_REMBRANDT

# Sound (AMD ACP)
sed -i 's/CONFIG_SND_SOC_AMD_ACP3x=m/CONFIG_SND_SOC_AMD_ACP3x=y/' .config
sed -i 's/CONFIG_SND_SOC_AMD_ACP5x=m/CONFIG_SND_SOC_AMD_ACP5x=y/' .config
sed -i 's/CONFIG_SND_SOC_AMD_ACP6x=m/CONFIG_SND_SOC_AMD_ACP6x=y/' .config
sed -i 's/CONFIG_SND_SOC_AMD_RPL_ACP6x=m/CONFIG_SND_SOC_AMD_RPL_ACP6x=y/' .config

# Media
scripts/config \
    -e MEDIA_SUPPORT \
    -e USB_VIDEO_CLASS

# Misc
scripts/config \
    -e ZRAM \
    -e I2C_PIIX4 \
    -e INTEL_RAPL \
    -e PERF_EVENTS_INTEL_RAPL \
    -e SENSORS_K10TEMP \
    -e USB_XHCI_PCI_RENESAS \
    -e X86_ACPI_CPUFREQ \
    -d DM_INIT

