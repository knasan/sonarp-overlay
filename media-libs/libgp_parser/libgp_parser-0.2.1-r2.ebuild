# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++23 Guitar Pro file parser (GP3–GP7)"
HOMEPAGE="https://github.com/sonar-project/libgp_parser"
# ${P} omits -rN and would collide with the old v0.2.1 distfile on mirrors.
SRC_URI="https://github.com/sonar-project/libgp_parser/archive/refs/tags/v${PVR}.tar.gz -> ${PF}.tar.gz"
# GitHub tag archives unpack to ${PN}-${PVR}/, not ${P}/.
S="${WORKDIR}/${PF}"

LICENSE="AGPL-3"
SLOT="0/0.2"
KEYWORDS="~amd64"
IUSE="examples test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/pugixml
	dev-libs/miniz:=
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-build/cmake-3.20"

src_configure() {
	local mycmakeargs=(
		-DLIBGP_PARSER_BUILD_EXAMPLE=$(usex examples)
		-DLIBGP_PARSER_BUILD_TESTS=$(usex test)
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	if use examples; then
		dobin "${BUILD_DIR}"/example/gp_info
		dobin "${BUILD_DIR}"/example/gp_score
	fi
}
