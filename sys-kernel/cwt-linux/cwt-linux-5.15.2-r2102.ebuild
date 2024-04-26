# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_MODULES_SIGN=true

inherit kernel-build

CWT_VER="21"
SDK_VER="5.11.3"

VF2_TAG="JH7110_VF2_515_v${SDK_VER}"
KV_LOCALVERSION="-cwt${CWT_VER}-v${SDK_VER}"

DESCRIPTION="Linux 5.15.x (-cwt) for StarFive RISC-V VisionFive 2 Board"
HOMEPAGE="https://github.com/cwt-vf2/linux-cwt-starfive-vf2"
SRC_URI="
	https://github.com/starfive-tech/linux/archive/refs/tags/${VF2_TAG}.tar.gz
"

S="${WORKDIR}/linux-${VF2_TAG}"

IUSE="
	debug
	+initramfs
	+modules-sign
	savedconfig
	secureboot
	+strip
	test
	+dracut
"
REQUIRED_USE="dracut"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~riscv"

DEPEND="
	sys-kernel/installkernel[dracut]
"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=(
	"${FILESDIR}/linux-00-5.15.0-5.15.2.patch"
	"${FILESDIR}/linux-01-Revert-fbcon-Disable_accelerated_scrolling.patch"
	"${FILESDIR}/linux-02-fbcon-Add_option_to_enable_legacy_hardware_acceleration.patch"
	"${FILESDIR}/linux-03-riscv-zba_zbb.patch"
	"${FILESDIR}/linux-04-eswin_6600u-llvm.patch"
	"${FILESDIR}/linux-05-fix_CVE-2022-0847_DirtyPipe.patch"
	"${FILESDIR}/linux-07-constify_struct_dh_pointer_members.patch"
	"${FILESDIR}/linux-08-fix_broken_gpu-drm-i2c-tda998x.patch"
	"${FILESDIR}/linux-09-fix_promisc_ethernet_driver_armbian.patch"
	"${FILESDIR}/linux-10-fix_unknown_relocation_type_57.patch"
)

src_prepare() {
	einfo "Copying over default config"
	cp "${FILESDIR}/config" "${S}/.config"

	default
	eapply_user
}