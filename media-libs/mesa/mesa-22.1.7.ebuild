# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit llvm meson-multilib python-any-r1 linux-info

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

SRC_URI="https://archive.mesa3d.org/${MY_P}.tar.xz"
KEYWORDS="~riscv"

LICENSE="MIT"
SLOT="0"
RESTRICT="!test? ( test )"

RADEON_CARDS="r300 r600 radeon radeonsi"
VIDEO_CARDS="${RADEON_CARDS} freedreno intel lima nouveau panfrost v3d vc4 virgl vivante vmware pvr"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	d3d9 debug gles1 +gles2 +llvm lm-sensors opencl osmesa selinux test
	unwind vaapi valgrind vdpau vulkan vulkan-overlay wayland +X xa xvmc
	zink +zstd +loader-force-pvr"

REQUIRED_USE="
	d3d9?   ( || ( video_cards_intel video_cards_r300 video_cards_r600 video_cards_radeonsi video_cards_nouveau video_cards_vmware ) )
	vulkan? ( video_cards_radeonsi? ( llvm ) )
	vulkan-overlay? ( vulkan )
	video_cards_radeonsi?   ( llvm )
	xa? ( X )
	xvmc? ( X )
	zink? ( vulkan )
	loader-force-pvr? ( video_cards_pvr )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.110"
RDEPEND="
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=media-libs/libglvnd-1.3.2[X?,${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]
	unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
	llvm? (
		video_cards_radeonsi? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
		video_cards_r600? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
		video_cards_radeon? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
	)
	lm-sensors? ( sys-apps/lm-sensors:=[${MULTILIB_USEDEP}] )
	opencl? (
				>=virtual/opencl-3[${MULTILIB_USEDEP}]
				dev-libs/libclc
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
	vaapi? (
		>=media-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
	)
	vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
	xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )
	selinux? ( sys-libs/libselinux[${MULTILIB_USEDEP}] )
	wayland? (
		>=dev-libs/wayland-1.18.0:=[${MULTILIB_USEDEP}]
	)
	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_intel?,video_cards_nouveau?,video_cards_vc4?,video_cards_vivante?,video_cards_vmware?,${MULTILIB_USEDEP}]
	vulkan-overlay? ( dev-util/glslang:0=[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	)
	zink? ( media-libs/vulkan-loader:=[${MULTILIB_USEDEP}] )
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )
"
for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done
RDEPEND="${RDEPEND}
	video_cards_radeonsi? ( ${LIBDRM_DEPSTRING}[video_cards_amdgpu] )
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 10.
# 3. Specify LLVM_MAX_SLOT, e.g. 9.
#LLVM_MAX_SLOT="14"
#LLVM_DEPSTR="
#	|| (
#		sys-devel/llvm:14[${MULTILIB_USEDEP}]
#		sys-devel/llvm:13[${MULTILIB_USEDEP}]
#	)
#	<sys-devel/llvm-$((LLVM_MAX_SLOT + 1)):=[${MULTILIB_USEDEP}]
#"
LLVM_MAX_SLOT="17"
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:14[${MULTILIB_USEDEP}]
		sys-devel/llvm:13[${MULTILIB_USEDEP}]
		sys-devel/llvm:17[${MULTILIB_USEDEP}]
	)
	<sys-devel/llvm-$((LLVM_MAX_SLOT + 1)):=[${MULTILIB_USEDEP}]
"
LLVM_DEPSTR_AMDGPU=${LLVM_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
CLANG_DEPSTR=${LLVM_DEPSTR//llvm/clang}
CLANG_DEPSTR_AMDGPU=${CLANG_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
RDEPEND="${RDEPEND}
	llvm? (
		opencl? (
			video_cards_r600? (
				${CLANG_DEPSTR_AMDGPU}
			)
			!video_cards_r600? (
				video_cards_radeonsi? (
					${CLANG_DEPSTR_AMDGPU}
				)
			)
			!video_cards_r600? (
				!video_cards_radeonsi? (
					video_cards_radeon? (
						${CLANG_DEPSTR_AMDGPU}
					)
				)
			)
			!video_cards_r600? (
				!video_cards_radeon? (
					!video_cards_radeonsi? (
						${CLANG_DEPSTR}
					)
				)
			)
		)
		!opencl? (
			video_cards_r600? (
				${LLVM_DEPSTR_AMDGPU}
			)
			!video_cards_r600? (
				video_cards_radeonsi? (
					${LLVM_DEPSTR_AMDGPU}
				)
			)
			!video_cards_r600? (
				!video_cards_radeonsi? (
					video_cards_radeon? (
						${LLVM_DEPSTR_AMDGPU}
					)
				)
			)
			!video_cards_r600? (
				!video_cards_radeon? (
					!video_cards_radeonsi? (
						${LLVM_DEPSTR}
					)
				)
			)
		)
	)
"
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}


DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	wayland? ( >=dev-libs/wayland-protocols-1.24 )
	X? (
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-base/xorg-proto
	)
"
BDEPEND="
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
	wayland? ( dev-util/wayland-scanner )
	app-text/dos2unix
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD=""



# TODO: Add depend on pvr WSI library
# TODO: fix llvm dependecy again

PATCHES=(
	"${FILESDIR}/0001-Add-PVR-Gallium-driver.patch"
	"${FILESDIR}/0002-dri-Add-some-new-DRI-formats-and-fourccs.patch"
	"${FILESDIR}/0003-GL_EXT_sparse_texture-entry-points.patch"
	"${FILESDIR}/0004-Add-support-for-various-GLES-extensions.patch"
	"${FILESDIR}/0005-Add-EGL_IMG_cl_image-extension.patch"
	"${FILESDIR}/0006-egl-optimise-eglMakeCurrent-for-the-case-where-nothi.patch"
	"${FILESDIR}/0007-GL_EXT_shader_pixel_local_storage2-entry-points.patch"
	"${FILESDIR}/0008-GL_IMG_framebuffer_downsample-entry-points.patch"
	"${FILESDIR}/0009-GL_OVR_multiview-entry-points.patch"
	"${FILESDIR}/0010-Add-OVR_multiview_multisampled_render_to_texture.patch"
	"${FILESDIR}/0011-wayland-drm-install-wayland-drm.xml-to-the-configure.patch"
	"${FILESDIR}/0012-Enable-buffer-sharing-in-the-kms_swrast-driver.patch"
	"${FILESDIR}/0013-egl-wayland-add-support-for-RGB565-back-buffers.patch"
	"${FILESDIR}/0014-egl-automatically-call-eglReleaseThread-on-thread-te.patch"
	"${FILESDIR}/0015-egl-wayland-post-maximum-damage-when-blitting.patch"
	"${FILESDIR}/0016-egl-wayland-flush-the-drawable-before-blitting.patch"
	"${FILESDIR}/0017-dri-use-a-supported-API-in-driCreateNewContext.patch"
	"${FILESDIR}/0018-gbm-add-gbm_bo_blit.patch"
	"${FILESDIR}/0019-gbm-don-t-assert-if-DRI-context-creation-fails.patch"
	"${FILESDIR}/0020-egl-wayland-add-pbuffer-support.patch"
	"${FILESDIR}/0021-egl-eglBindAPI-workaround-for-dEQP-bug.patch"
	"${FILESDIR}/0022-GL_EXT_multi_draw_indirect-entry-points.patch"
	"${FILESDIR}/0023-dri-add-support-for-YUV-DRI-config.patch"
	"${FILESDIR}/0024-egl-add-support-for-EXT_yuv_surface.patch"
	"${FILESDIR}/0025-dri-add-missing-__DRI_IMAGE_COMPONENTS-define-for-EG.patch"
	"${FILESDIR}/0026-egl-wayland-expose-EXT_yuv_surface-support.patch"
	"${FILESDIR}/0027-gbm-add-some-new-GBM-formats.patch"
	"${FILESDIR}/0028-egl-add-null-platform.patch"
	"${FILESDIR}/0029-egl-add-support-for-EXT_image_gl_colorspace.patch"
	"${FILESDIR}/0030-meson-force-C-2011-for-thread_local.patch"
	"${FILESDIR}/0031-dri2-add-support-for-swap-intervals-other-than-1.patch"
	"${FILESDIR}/0032-null_platform-add-support-for-explicit-synchronisati.patch"
	"${FILESDIR}/0033-egl-null-add-support-for-DRM-image-format-modifiers.patch"
	"${FILESDIR}/0034-egl-query-the-supported-ES2-context-version.patch"
	"${FILESDIR}/0035-meson-allow-libGL-to-be-built-without-GLX.patch"
	"${FILESDIR}/0036-egl-wayland-process-non-resized-window-movement.patch"
	"${FILESDIR}/0037-Separate-EXT_framebuffer_object-from-ARB-version.patch"
	"${FILESDIR}/0038-egl-null-add-support-for-async-flip-with-front-buffe.patch"
	"${FILESDIR}/0039-gbm-add-pbuffer-support.patch"
	"${FILESDIR}/0040-egl-null-expose-EXT_yuv_surface-support.patch"
	"${FILESDIR}/0041-dri-preserve-the-original-FD-for-driver-use.patch"
	"${FILESDIR}/0042-egl-wayland-a-linear-buffer-is-not-needed-with-DRM-f.patch"
	"${FILESDIR}/0043-dri3-a-linear-buffer-is-not-needed-with-DRM-format-m.patch"
	"${FILESDIR}/0044-egl-drm-add-support-for-DRI_PRIME-GPU-selection.patch"
	"${FILESDIR}/0045-egl-null-add-support-for-DRI_PRIME-GPU-selection.patch"
	"${FILESDIR}/0046-egl-null-introduce-NULL_DRM_DISPLAY.patch"
	"${FILESDIR}/0047-vulkan-wsi-check-the-DRI3-and-Present-XCB-reply-poin.patch"
	"${FILESDIR}/0048-vulkan-wsi-make-the-display-FD-available.patch"
	"${FILESDIR}/0049-pvr-wsi-add-PowerVR-Vulkan-WSI-library.patch"
	"${FILESDIR}/0050-vulkan-wsi-Disable-use-of-VK_EXT_pci_bus_info.patch"
	"${FILESDIR}/0051-vulkan-wsi-default-to-force_bgra8_unorm_first-true.patch"
	"${FILESDIR}/0052-vulkan-wsi-enable-additional-formats-for-Display.patch"
	"${FILESDIR}/0053-mesa-partially-revert-pbuffer-attribute-removal.patch"
	"${FILESDIR}/0054-egl_dri2-set-pbuffer-config-attribs-to-0-for-non-pbu.patch"
	"${FILESDIR}/0055-GL_ARB_geometry_shader4-entry-points.patch"
	"${FILESDIR}/0056-egl-wayland-add-EGL_BUFFER_PRESERVED-support.patch"
	"${FILESDIR}/0057-glapi-restore-exec-dynamic.patch"
	"${FILESDIR}/0058-Revert-meson-check-mtls-if-has_exe_wrapper.patch"
	"${FILESDIR}/0059-gbm-add-GBM_FORMAT_AXBXGXRX106106106106.patch"
	"${FILESDIR}/0060-gallium-pvr-Add-DRM_FORMAT_AXBXGXRX106106106106.patch"
	"${FILESDIR}/0061-gallium-pvr-add-the-DRIconfigOptions-extension.patch"
	"${FILESDIR}/0062-gallium-pvr-support-DRI-Image-extension-v21.patch"
)


llvm_check_deps() {
	local flags=${MULTILIB_USEDEP}
	if use video_cards_r600 || use video_cards_radeon || use video_cards_radeonsi
	then
		flags+=",llvm_targets_AMDGPU(-)"
	fi

	if use opencl; then
		has_version "sys-devel/clang:${LLVM_SLOT}[${flags}]" || return 1
	fi
	has_version "sys-devel/llvm:${LLVM_SLOT}[${flags}]"
}

pkg_pretend() {
	if use loader-force-pvr; then
		if use video_cards_r300 ||
		   use video_cards_r600 ||
		   use video_cards_radeon ||
		   use video_cards_radeonsi ||
		   use video_cards_freedreno ||
		   use video_cards_intel ||
		   use video_cards_lima ||
		   use video_cards_nouveau ||
		   use video_cards_panfrost ||
		   use video_cards_v3d ||
		   use video_cards_vc4 ||
		   use video_cards_virgl ||
		   use video_cards_vivante ||
		   use video_cards_vmware; then
			ewarn "The loader-force-pvr useflag is enable. This will force mesa to ALWAYS pick the pvr card."
			ewarn "You have selected other cards besides the pvr card in VIDEO_CARDS."
			ewarn "As loader-force-pvr is enabled all other cards besides pvr are effectively rendered useless."
			ewarn "I doubt this is the behaviour you are looking for."
			ewarn "I recommend either disabling loader-force-pvr or the other video cards."
		fi
	fi

	if use vulkan; then
		if ! use video_cards_freedreno &&
		   ! use video_cards_intel &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_v3d &&
		   ! use video_cards_pvr; then
			ewarn "Ignoring USE=vulkan     since VIDEO_CARDS does not contain freedreno, intel, radeonsi, or v3d"
		fi
	fi

	if use opencl; then
		if ! use video_cards_r600 &&
		   ! use video_cards_radeonsi; then
			ewarn "Ignoring USE=opencl     since VIDEO_CARDS does not contain r600 or radeonsi"
		fi
	fi

	if use vaapi; then
		if ! use video_cards_r600 &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=vaapi      since VIDEO_CARDS does not contain r600, radeonsi, or nouveau"
		fi
	fi

	if use vdpau; then
		if ! use video_cards_r300 &&
		   ! use video_cards_r600 &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=vdpau      since VIDEO_CARDS does not contain r300, r600, radeonsi, or nouveau"
		fi
	fi

	if use xa; then
		if ! use video_cards_freedreno &&
		   ! use video_cards_nouveau &&
		   ! use video_cards_vmware; then
			ewarn "Ignoring USE=xa         since VIDEO_CARDS does not contain freedreno, nouveau, or vmware"
		fi
	fi

	if use xvmc; then
		if ! use video_cards_r600 &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=xvmc       since VIDEO_CARDS does not contain r600 or nouveau"
		fi
	fi

	if ! use llvm; then
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain llvm"
	fi

	if use osmesa && ! use llvm; then
		ewarn "OSMesa will be slow without enabling USE=llvm"
	fi
}

python_check_deps() {
	python_has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use video_cards_intel ||
	   use video_cards_radeonsi; then
		if kernel_is -ge 5 11 3; then
			CONFIG_CHECK="~KCMP"
		elif kernel_is -ge 5 11; then
			CONFIG_CHECK="~CHECKPOINT_RESTORE"
		elif kernel_is -ge 5 10 20; then
			CONFIG_CHECK="~KCMP"
		else
			CONFIG_CHECK="~CHECKPOINT_RESTORE"
		fi
		linux-info_pkg_setup
	fi

	if use llvm; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
}

src_prepare() {
	use loader-force-pvr && PATCHES+=(
		"${FILESDIR}/0002-Force-Mesa-to-use-the-PVR-driver-for-platform-device.patch"
	)
	dos2unix src/mesa/main/formats.csv

	default_src_prepare
}

multilib_src_configure() {
	local emesonargs=()

	local platforms
	use X && platforms+="x11"
	use wayland && platforms+=",wayland"
	emesonargs+=(-Dplatforms=${platforms#,})

	if use video_cards_intel ||
	   use video_cards_r300 ||
	   use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau ||
	   use video_cards_vmware; then
		emesonargs+=($(meson_use d3d9 gallium-nine))
	else
		emesonargs+=(-Dgallium-nine=false)
	fi

	if use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau; then
		emesonargs+=($(meson_feature vaapi gallium-va))
		use vaapi && emesonargs+=( -Dva-libs-path="${EPREFIX}"/usr/$(get_libdir)/va/drivers )
	else
		emesonargs+=(-Dgallium-va=disabled)
	fi

	if use video_cards_r300 ||
	   use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau; then
		emesonargs+=($(meson_feature vdpau gallium-vdpau))
	else
		emesonargs+=(-Dgallium-vdpau=disabled)
	fi

	if use video_cards_freedreno ||
	   use video_cards_nouveau ||
	   use video_cards_vmware; then
		emesonargs+=($(meson_feature xa gallium-xa))
	else
		emesonargs+=(-Dgallium-xa=disabled)
	fi

	if use video_cards_r600 ||
	   use video_cards_nouveau; then
		emesonargs+=($(meson_feature xvmc gallium-xvmc))
	else
		emesonargs+=(-Dgallium-xvmc=disabled)
	fi

	if use video_cards_freedreno ||
	   use video_cards_lima ||
	   use video_cards_panfrost ||
	   use video_cards_v3d ||
	   use video_cards_vc4 ||
	   use video_cards_vivante; then
		gallium_enable -- kmsro
	fi

	gallium_enable -- swrast
	gallium_enable video_cards_freedreno freedreno
	gallium_enable video_cards_intel crocus i915 iris
	gallium_enable video_cards_lima lima
	gallium_enable video_cards_nouveau nouveau
	gallium_enable video_cards_panfrost panfrost
	gallium_enable video_cards_v3d v3d
	gallium_enable video_cards_vc4 vc4
	gallium_enable video_cards_virgl virgl
	gallium_enable video_cards_vivante etnaviv
	gallium_enable video_cards_vmware svga
	gallium_enable video_cards_pvr pvr
	gallium_enable zink zink

	gallium_enable video_cards_r300 r300
	gallium_enable video_cards_r600 r600
	gallium_enable video_cards_radeonsi radeonsi
	if ! use video_cards_r300 && \
		! use video_cards_r600; then
		gallium_enable video_cards_radeon r300 r600
	fi

	# opencl stuff
	emesonargs+=(
		-Dgallium-opencl="$(usex opencl icd disabled)"
	)

	if use vulkan; then
		vulkan_enable video_cards_freedreno freedreno
		vulkan_enable video_cards_intel intel
		vulkan_enable video_cards_radeonsi amd
		vulkan_enable video_cards_v3d broadcom
		vulkan_enable video_cards_pvr pvr
	fi

	driver_list() {
		local drivers="$(sort -u <<< "${1// /$'\n'}")"
		echo "${drivers//$'\n'/,}"
	}

	local vulkan_layers
	use vulkan && vulkan_layers+="device-select"
	use vulkan-overlay && vulkan_layers+=",overlay"
	emesonargs+=(-Dvulkan-layers=${vulkan_layers#,})

	emesonargs+=(
		$(meson_use test build-tests)
		-Dglx=$(usex X dri disabled)
		-Dshared-glapi=enabled
		-Ddri3=enabled
		-Degl=enabled
		-Dgbm=enabled
		-Dglvnd=true
		$(meson_feature gles1)
		$(meson_feature gles2)
		$(meson_feature llvm)
		$(meson_feature lm-sensors lmsensors)
		$(meson_use osmesa)
		$(meson_use selinux)
		$(meson_feature unwind libunwind)
		$(meson_feature zstd)
		-Dvalgrind=$(usex valgrind auto disabled)
		-Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")
		-Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

multilib_src_test() {
	meson_src_test -t 100
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of DRI drivers to enable
gallium_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		GALLIUM_DRIVERS+=("$@")
	fi
}

vulkan_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		VULKAN_DRIVERS+=("$@")
	fi
}