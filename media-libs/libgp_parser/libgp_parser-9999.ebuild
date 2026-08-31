# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="C++23 Guitar Pro file parser (GP3–GP7)"
HOMEPAGE="https://github.com/sonar-project/libgp_parser"
EGIT_REPO_URI="https://github.com/sonar-project/libgp_parser.git"
# Local live builds: EGIT_REPO_URI="file:///home/smk/Develop/Projects/libgp_parser"

LICENSE="AGPL-3"
SLOT="0/0.2"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/pugixml
	dev-libs/miniz:=
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-build/cmake-3.20"

src_configure() {
	local mycmakeargs=(
		-DLIBGP_PARSER_BUILD_EXAMPLE=OFF
		-DLIBGP_PARSER_BUILD_TESTS=$(usex test)
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}
