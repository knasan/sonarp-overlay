# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop git-r3 xdg

DESCRIPTION="Practice hub for Guitar Pro, audio, and learning material"
HOMEPAGE="https://github.com/sonar-project/SonarPractice"
EGIT_REPO_URI="https://github.com/sonar-project/SonarPractice.git"
EGIT_COMMIT="v${PV}"
LICENSE="AGPL-3 MPL-2.0 Apache-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ffmpeg webengine"

DEPEND="
	>=media-libs/libgp_parser-0.2.1:=
	>=media-libs/rubberband-4.0.0:=
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

src_prepare() {
	sed -i "s/^project(SonarPractice VERSION .*/project(SonarPractice VERSION ${PV})/" \
		CMakeLists.txt || die

	# v0.1.0 still FetchContents libgp_parser + rubberband; force system packages.
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

find_package(libgp_parser 0.2 REQUIRED)
message(STATUS "Using system libgp_parser")
EOF

	cat > cmake/FindRubberband.cmake <<'EOF' || die
find_package(PkgConfig REQUIRED)
pkg_check_modules(RUBBERBAND REQUIRED IMPORTED_TARGET GLOBAL rubberband)
add_library(SonarPractice::Rubberband ALIAS PkgConfig::RUBBERBAND)
message(STATUS "Using system Rubber Band ${RUBBERBAND_VERSION}")
EOF

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
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
