# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

IUSE="+pvr-gpu +wifi +bluetooth +wave5"

vf2_tag="JH7110_VF2_515_v${PV}"

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="
	https://github.com/starfive-tech/buildroot/archive/refs/tags/${vf2_tag}.tar.gz
	wave5? ( https://gitlab.collabora.com/chipsnmedia/linux-firmware/-/raw/cnm/cnm/wave511_dec_fw.bin )
"

S="${WORKDIR}/${vf2_tag}"

LICENSE=""
SLOT="0"
KEYWORDS="~riscv"

DEPEND="
	pvr-gpu? ( sys-firmware/vf2-pvr-firmware )
"
RDEPEND="${DEPEND}"
BDEPEND=""

fw_path="package/starfive/starfive-firmware"

src_install() {

	# wifi firmware
	if use wifi; then
		insinto /lib/firmware

		doins ${fw_path}/ECR6600U-usb-wifi/ECR6600U_transport.bin
		doins ${fw_path}/ap6256-sdio-wifi/*

		doins -r ${fw_path}/aic8800-usb-wifi/aic8800
		doins -r ${fw_path}/aic8800-usb-wifi/aic8800DC
	fi

	# bluetooth firmware
	if use bluetooth; then
		insinto /lib/firmware

		doins ${fw_path}/ap6256-bluetooth/BCM4345C5.hcd
		doins ${fw_path}/rtl8852bu-bluetooth/*
	fi

	# Wave5 firmware
	if use Wave5; then
		insinto /lib/firmware

		doins ${WORKDIR}/wave511_dec_fw.bin
	fi

}


