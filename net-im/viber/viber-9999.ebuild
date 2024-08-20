# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop multilib-build optfeature pax-utils unpacker xdg

DESCRIPTION="Free and secure calls and messages to anyone, anywhere"
HOMEPAGE="https://www.viber.com/"
SRC_URI="https://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"

QA_PRESTRIPPED="
	opt/viber/Viber
	opt/viber/libexec/QtWebEngineProcess
	opt/viber/lib/libicudata.so.66
	opt/viber/lib/libssl.so.1.1
	opt/viber/lib/libcrypto.so.1.1
	opt/viber/lib/libXcomposite.so.1
	opt/viber/lib/libwebp.so.6
	opt/viber/lib/libicui18n.so.66
	opt/viber/lib/libqrencode.so
	opt/viber/lib/libViberRTC.so
	opt/viber/lib/libminizip.so.1
	opt/viber/lib/libdouble-conversion.so.3
	opt/viber/lib/libicuuc.so.66
	opt/viber/lib/libpng16.so.16
	opt/viber/lib/libXdamage.so.1
	opt/viber/lib/libb2.so.1
	opt/viber/lib/libjpeg.so.8
	opt/viber/lib/libpcre2-16.so.0
	opt/viber/lib/libre2.so.5
	opt/viber/lib/libxcb-cursor.so.0
"

LICENSE="Viber"
SLOT="0"
KEYWORDS="amd64"
IUSE="+abi_x86_64 apulse +pulseaudio"
REQUIRED_USE="
	^^ ( apulse pulseaudio )
"
RESTRICT="bindist mirror"

BDEPEND="
	sys-apps/fix-gnustack
"
RDEPEND="
	app-arch/brotli
	app-arch/snappy
	app-arch/zstd
	app-crypt/mit-krb5
	dev-libs/expat
	dev-libs/glib
	dev-libs/libevent
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/gst-plugins-bad
	media-libs/gst-plugins-base
	media-libs/gst-plugins-good
	media-plugins/gst-plugins-libav
	media-libs/gstreamer
	media-libs/harfbuzz
	media-libs/lcms
	media-libs/libglvnd
	media-libs/libmng
	media-libs/libwebp
	media-libs/opus
	media-libs/mesa
	media-libs/tiff-compat
	net-print/cups
	sys-apps/dbus
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils[udev]
	)
	sys-libs/mtdev
	sys-libs/zlib
	x11-libs/gdk-pixbuf
	x11-libs/gtk+
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-libs/tslib
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	apulse? ( media-sound/apulse )
	pulseaudio? (
		media-libs/libpulse[glib]
		media-plugins/gst-plugins-pulse
	)
"

S="${WORKDIR}"

src_prepare() {
	default

	if use apulse ; then
		sed -i '/Exec=/s|/opt|apulse /opt|' \
			usr/share/applications/viber.desktop || die "sed failed"
	fi

	# remove hardcoded path
	sed -i '/Icon/s|/usr/share/pixmaps/viber.png|viber|' \
		usr/share/applications/viber.desktop \
		|| die "sed failed for viber.desktop"
}

src_install() {
	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg \
		viber.svg

        for icon in "usr/share/viber/"*.png; do
                size=${icon##*/${PN}\/}
                size=${size%.png}
                dodir "usr/share/icons/hicolor/${size}/apps"
                newicon -s ${size%%x*} "$icon" ${PN}.png
        done

	dosym ../icons/hicolor/96x96/apps/viber.png \
		/usr/share/pixmaps/viber.png

	domenu usr/share/applications/viber.desktop

	insinto /opt/viber
	doins -r opt/viber/.

	pax-mark -m "${ED}"/opt/viber/Viber \
			"${ED}"/opt/viber/QtWebEngineProcess

	fix-gnustack -f "${ED}"/opt/viber/lib/libQt6WebEngineCore.so.6 > /dev/null \
		|| die "removing execstack flag failed"

	fperms +x /opt/viber/Viber \
		/opt/viber/lib/libQt6Core.so.6 \
		/opt/viber/libexec/QtWebEngineProcess

	dosym ../../opt/viber/Viber /usr/bin/Viber
}

pkg_postinst() {
	optfeature "ffmpeg backend", media-video/ffmpeg:0
	xdg_desktop_database_update
}

