TERMUX_PKG_HOMEPAGE=https://botan.randombit.net/
TERMUX_PKG_DESCRIPTION="Crypto and TLS for Modern C++"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux"
# This specific package is for libbotan-3.
TERMUX_PKG_VERSION="3.6.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://botan.randombit.net/releases/Botan-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=7cb8575d88d232c77174769d7f9e24bb44444160585986eebd66e749cb9a9089
TERMUX_PKG_DEPENDS="libbz2, libc++, liblzma, libsqlite, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost, boost-headers"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--cpu=$TERMUX_ARCH
--os=android
--no-install-python-module
--without-documentation
--with-boost
--with-bzip2
--with-lzma
--with-sqlite3
--with-zlib
--prefix=$TERMUX_PREFIX
--program-suffix=$(echo ${TERMUX_PKG_VERSION#*:} | cut -d . -f 1)
"

# Fix for boost 1.87
# NOTE: Remove after version 3.7.0 release in February.
# See https://github.com/randombit/botan/issues/4505
termux_step_post_get_source() {
	local patch_file="$TERMUX_PKG_TMPDIR/boost1_87-fix.patch"
	termux_download https://github.com/randombit/botan/commit/2a406beab449a2cb310fa543451a7087ca7b4b1a.patch \
		"$patch_file" \
		6eae04e44bfab9a24ff997a3569229fcf14173733b32f764ca5962a0d773eac9
	(
		cd "$TERMUX_PKG_SRCDIR" || exit
		patch -p1 <"$patch_file"
	)
}

termux_step_pre_configure() {
	CXXFLAGS+=" $CPPFLAGS"
}

termux_step_configure() {
	python3 $TERMUX_PKG_SRCDIR/configure.py \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

termux_step_post_massage() {
	local _GUARD_FILE="lib/libbotan-3.so"
	if [ ! -e "${_GUARD_FILE}" ]; then
		termux_error_exit "Error: file ${_GUARD_FILE} not found."
	fi
}
