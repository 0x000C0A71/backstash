# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 flag-o-matic

DESCRIPTION=""
HOMEPAGE=""

EGIT_REPO_URI="https://github.com/Unvanquished/Unvanquished.git" 
EGIT_SUBMODULES=(
	'*'
)

if [[ ${PV} != 9999 ]]; then
	EGIT_COMMIT="v${PV}"
fi


LICENSE=""
SLOT="0"
KEYWORDS="~amd64"


#cmake .. -DDAEMON_CBSE_PYTHON_PATH=/usr/bin/python3.11

DEPEND="
	sys-libs/zlib
	dev-libs/gmp
	dev-libs/nettle
	net-misc/curl[curl_ssl_gnutls]
	media-libs/libsdl2
	media-libs/glew
	media-libs/libpng
	media-libs/libjpeg-turbo
	media-libs/libwebp
	media-libs/freetype
	dev-lang/lua
	media-libs/openal
	media-libs/libogg
	media-libs/libvorbis
	media-libs/opusfile
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-python/pyyaml
	dev-python/jinja
"

PATCHES=(
	"${FILESDIR}/NoNacl.patch"
	"${FILESDIR}/so.patch"
)

CMAKE_BUILD_TYPE=Release

src_configure() {
	local mycmakeargs=(
		-DDAEMON_CBSE_PYTHON_PATH=/usr/bin/python
		
		
		
		-DBUILD_GAME_NACL=OFF
		-DBUILD_GAME_NATIVE_DLL=OFF
		-DBUILD_GAME_NATIVE_EXE=ON

		#$(cmake_use_find_package foo LibFoo)
	)

	if [[ ${CMAKE_BUILD_TYPE} != Debug ]]; then
		append-cxxflags -DNDEBUG
	fi


	cmake_src_configure

	sed 's/set(BUILD_SHARED_LIBS ON CACHE BOOL "")//' ${BUILD_DIR}/gentoo_common_config.cmake > ${BUILD_DIR}/gentoo_common_config.cmake || die "Cannot fix cmake config"
}
