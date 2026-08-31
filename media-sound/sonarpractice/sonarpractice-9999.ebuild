# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop git-r3 xdg

DESCRIPTION="Practice hub for Guitar Pro, audio, and learning material"
HOMEPAGE="https://github.com/sonar-project/SonarPractice"
EGIT_REPO_URI="https://github.com/sonar-project/SonarPractice.git"
# Local live builds: EGIT_REPO_URI="file:///home/smk/Develop/Projects/SonarPractice"

SRC_URI="
	https://github.com/breakfastquay/rubberband/archive/refs/tags/v4.0.0.tar.gz
		-> rubberband-4.0.0.tar.gz
"

LICENSE="AGPL-3 MPL-2.0 Apache-2.0 OFL-1.1 GPL-2"
SLOT="0"
IUSE="ffmpeg webengine"

DEPEND="
	=media-libs/libgp_parser-9999
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
	git-r3_src_unpack
	# rubberband tarball still needed for FetchContent
	local rubberband="${DISTDIR}/rubberband-4.0.0.tar.gz"
	mkdir -p "${WORKDIR}" || die
	tar -C "${WORKDIR}" -xzf "${rubberband}" || die
	mv "${WORKDIR}/rubberband-4.0.0" "${WORKDIR}/rubberband" || die
}

src_prepare() {
	sed -i 's/add_library(SonarPractice_Rubberband SHARED/add_library(SonarPractice_Rubberband STATIC/' \
		cmake/FindRubberband.cmake || die
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
