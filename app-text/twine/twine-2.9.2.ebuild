# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Twine is an open-source tool for telling interactive, nonlinear stories."
HOMEPAGE="www.twinery.org"
SRC_URI="https://github.com/klembot/twinejs/releases/download/${PV}/Twine-${PV}-Linux-x64.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="app-arch/unzip"

src_unpack() {
	mkdir -p "${S}" || die "mkdir failed"
	cd "${S}" || die "cd failed"
	unpack "${A}"
}

src_install() {
	dodir /opt/twine
	cp -R "${S}"/* "${D}/opt/twine" || die "Install failed!"

	newbin "${FILESDIR}/run.sh" twine

	insinto /usr/share/applications
	doins "${FILESDIR}"/twine.desktop

	insinto /usr/share/icons
	doins "${FILESDIR}"/twine.svg
}
