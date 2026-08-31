# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop xdg

DESCRIPTION="Practice hub for Guitar Pro, audio, and learning material"
HOMEPAGE="https://github.com/sonar-project/SonarPractice"
SRC_URI="
	https://github.com/sonar-project/SonarPractice/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/breakfastquay/rubberband/archive/refs/tags/v4.0.0.tar.gz
		-> rubberband-4.0.0.tar.gz
"

LICENSE="AGPL-3 MPL-2.0 Apache-2.0 OFL-1.1 GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ffmpeg webengine"

DEPEND="
	>=media-libs/libgp_parser-0.2.1:=
	>=dev-qt/qtbase-6.11:6[concurrent,gui,sql,sqlite,widgets]
	>=dev-qt/qtdeclarative-6.11:6[widgets]
	>=dev-qt/qtmultimedia-6.11:6
	>=dev-qt/qtsvg-6.11:6
	ffmpeg? ( media-video/ffmpeg:= )
	webengine? ( >=dev-qt/qtwebengine-6.11:6[qml] )
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-build/cmake-3.20
	virtual/pkgconfig
	>=dev-qt/qttools-6.11:6[linguist]
"

src_unpack() {
	default
	mv "${WORKDIR}/rubberband-4.0.0" "${WORKDIR}/rubberband" || die
}

src_prepare() {
	sed -i "s/^project(SonarPractice VERSION .*/project(SonarPractice VERSION ${PV})/" \
		CMakeLists.txt || die
	sed -i 's/add_library(SonarPractice_Rubberband SHARED/add_library(SonarPractice_Rubberband STATIC/' \
		cmake/FindRubberband.cmake || die

	# v0.1.0 and earlier always FetchContent libgp_parser; prefer the system package.
	cat > cmake/Dependencies.cmake <<'EOF' || die
# cmake/Dependencies.cmake
# External dependencies for SonarPractice.

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

include(AqtSqlPluginWorkaround)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Concurrent
    Multimedia
    Sql
    Test
    Quick
    QuickControls2
    QuickDialogs2
    Qml
    QuickTest
    Widgets
)

# Optional: AlphaTab player via Qt WebEngine (ASCII preview remains the fallback).
set(SONARPRACTICE_HAS_WEBENGINE OFF)
find_package(Qt6 QUIET COMPONENTS WebEngineQuick)
if(TARGET Qt6::WebEngineQuick)
    set(SONARPRACTICE_HAS_WEBENGINE ON)
    message(STATUS "Qt WebEngineQuick found — Guitar Pro AlphaTab player enabled")
else()
    message(STATUS "Qt WebEngineQuick not found — Guitar Pro ASCII preview only")
endif()

include(FindRubberband)
include(FindFFmpeg)

include(FetchContent)

find_package(libgp_parser 0.2 REQUIRED)
message(STATUS "Using system libgp_parser")
EOF

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_RUBBERBAND="${WORKDIR}/rubberband"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	newicon -s scalable assets/svg/icon.svg sonarpractice.svg
	local desktop="${T}/sonarpractice.desktop"
	sed -e 's|^Exec=.*|Exec=SonarPractice|' \
		-e 's|^Icon=.*|Icon=sonarpractice|' \
		sonarpractice.desktop > "${desktop}" || die
	domenu "${desktop}"
}
