#!/bin/bash

: ${ARCH:="i686"}

: ${HOST:="${ARCH}-w64-mingw32"}

: ${MINGW_ROOT:="/usr/$HOST/sys-root/mingw"}

function set_msys2_env ()
{
	export PYTHON=/usr/bin/python3
	export MINGW_ROOT=/mingw32
	export PKG_CONFIG_LIBDIR=$MINGW_ROOT/lib/pkgconfig
	export PKGCONFIG=/usr/bin/pkg-config
	export WINRC=windres
	export AR=$HOST-gcc-ar
}

function detect_build_host ()
{
	if [ $(grep -ow -E [[:digit:]]+ /etc/system-release) == "19" ]; then
		BUILD_HOST='Fedora-19'
	elif [ $(grep -ow -E [[:digit:]]+ /etc/system-release) == "20" ]; then
		BUILD_HOST='Fedora-20'
	elif [ $(grep -ow -E [[:digit:]]+ /etc/system-release) == "21" ]; then
		BUILD_HOST='Fedora-21'
	elif [ -n "${MSYSTEM}" ]; then
		BUILD_HOST='MSYS2'
		set_msys2_env
	else
		echo "Cannot determine build host....exiting"
		exit 1
	fi
	echo "Build host ${BUILD_HOST} detected"
}

function export_tools ()
{
	export PKG_CONFIG_PREFIX=${PKG_CONFIG_PREFIX:=$MINGW_ROOT}
	export PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:=$MINGW_ROOT/lib/pkgconfig}
	export PKGCONFIG=${PKGCONFIG:=pkg-config}
	export AR=${AR:=$HOST-ar}
	export RANLIB=${RANLIB:=$HOST-ranlib}
	export CC=${CC:=$HOST-gcc}
	export CPP=${CPP:=$HOST-g++}
	export CXX=${CXX:=$HOST-g++}
	export AS=${AS:=$HOST-as}
	export LINK_CC=${LINK_CC:=$HOST-gcc}
	export LINK_CXX=${LINK_CXX:=$HOST-g++}
	export WINRC=${WINRC:=$HOST-windres}
	export STRIP=${STRIP:=$HOST-strip}
	export PYTHON=${PYTHON:=python}
}

function define_standard_dirs
{
	PKG_BIN_DIR=$PKG_INSTALL_DIR/bin
	PKG_LIB_DIR=$PKG_INSTALL_DIR/lib
	PKG_ETC_DIR=$PKG_INSTALL_DIR/etc
	PKG_SHARE_DIR=$PKG_INSTALL_DIR/share
}

# a package could override this if necessary
function copydll () {
	if [ -f $MINGW_ROOT/bin/$1 ]; then
		cp $MINGW_ROOT/bin/$1 $2 || return 1
		return 0
	fi

	echo "ERROR: File $1 does not exist"
	return 1
}

function prep ()
{
	echo "Package $MINGW_PKG_NAME using default prep"
}

function build ()
{
	echo "Package $MINGW_PKG_NAME using default build"
}

function install ()
{
	echo "Package $MINGW_PKG_NAME using default install"
}

function package ()
{
	echo "Package $MINGW_PKG_NAME using default package"
	echo "Creating tarball from $PKG_INSTALL_DIR ..."
	cd $PKG_INSTALL_DIR
	echo "pwd: "
	pwd
	# This won't pick up any hidden files, not sure we need to?
	tar -cvJf $PKG_INSTALL_DIR.tar.xz *
	cd -
}

function clean ()
{
	echo "Package $MINGW_PKG_NAME using default clean"

	if [ -d "$PKG_INSTALL_DIR" ]; then
		echo "Removing $PKG_INSTALL_DIR"
		rm -rf "$PKG_INSTALL_DIR" || exit 1
	fi
}

function print_usage ()
{
	echo "usage: mingw-pkg [-d] [-h] <command> <package>"
	echo " "
	echo "The commands are:"
	echo "    prep"
	echo "    build"
	echo "    install"
	echo "    package"
	echo "    clean"
}

function check_pkg_env ()
{
	if [ -z "${PKG_NAME}" ]; then
		echo "Package $MINGW_PKG_NAME needs to set PKG_NAME"
		exit 1
	fi
	if [ -z "${PKG_VERSION}" ]; then
		echo "Package $MINGW_PKG_NAME needs to set PKG_VERSION"
		exit 1
	fi
}

OPTIND=1
while getopts "h?dvi:" opt; do
	case "$opt" in
		h)
			print_usage
			exit 0
			;;
		v)
			MINGW_PKG_VERBOSE=1
			set -x
			;;
		d)
			MINGW_PKG_ENABLE_DEBUG=1
			;;
		i)
			MINGW_PKG_OVERRIDE_INSTALL_DIR=$OPTARG
			;;
	esac
done
shift "$((OPTIND-1))"

if [ -z $1 ] && [ -z $2 ]; then
		print_usage
		echo "You must specify command and package name"
		exit 1
fi

MINGW_PKG_COMMAND="$1"
MINGW_PKG_NAME="$2"
MINGW_PKG_SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
MINGW_PKG_DIRECTORY="$MINGW_PKG_SCRIPT_PATH/packages/$2"
MINGW_PKG_FILE="$MINGW_PKG_DIRECTORY/MINGWPKG"

echo "Building Package $2"

if [ ! -d $MINGW_PKG_DIRECTORY ] && [ ! -f $MINGW_PKG_FILE ]; then
	echo "No MINGWPKG file exists at $MINGW_PKG_FILE"
	exit 1
fi

detect_build_host
export_tools

# source the package file to get variables and functions
. $MINGW_PKG_FILE

define_package_env
check_pkg_env

MINGW_PKG_BUILD_DIR="$MINGW_PKG_SCRIPT_PATH/BUILD"
mkdir -p $MINGW_PKG_BUILD_DIR

# install directly into MINGW_PKG_INSTALL_DIR dir if defined
if [ -z $MINGW_PKG_INSTALL_DIR ]; then
	MINGW_PKG_INSTALL_DIR="$MINGW_PKG_SCRIPT_PATH/INSTALL"
	echo "Installing packages to $MINGW_PKG_INSTALL_DIR as MINGW_PKG_INSTALL_DIR is not defined"
fi

# Figure out the Build Type
if [ -n "$MINGW_PKG_ENABLE_DEBUG" ]; then
	PKG_INSTALL_DIR_NAME="${PKG_NAME}-${PKG_VERSION}-${ARCH}-dbg"
else
	PKG_INSTALL_DIR_NAME="${PKG_NAME}-${PKG_VERSION}-${ARCH}"
fi
PKG_INSTALL_DIR="$MINGW_PKG_INSTALL_DIR/$PKG_INSTALL_DIR_NAME"

if [ -n "${MINGW_PKG_OVERRIDE_INSTALL_DIR}" ]; then
	PKG_INSTALL_DIR="$MINGW_PKG_OVERRIDE_INSTALL_DIR"
	echo "Using install dir $PKG_INSTALL_DIR"
fi

define_standard_dirs

if [ -n "${MINGW_PKG_VERBOSE}" ]; then
	VERBOSE_FLAGS=-v
fi

if [ -n "${MINGW_PKG_ENABLE_DEBUG}" ]; then
	DEBUG_FLAGS=-d
fi

MINGW_PKG_CACHE_DIR="$PKG_INSTALL_DIR/mingw-pkg"

for pkg in $PKG_DEPS
do
	if [ ! -e "$MINGW_PKG_CACHE_DIR/$pkg" ]; then
		echo "Building package dependency $pkg"
		$MINGW_PKG_SCRIPT_PATH/mingw-pkg.sh $VERBOSE_FLAGS $DEBUG_FLAGS -i $PKG_INSTALL_DIR $MINGW_PKG_COMMAND $pkg || exit 1
		if [ $MINGW_PKG_COMMAND == 'install' ]; then
			mkdir -p "$MINGW_PKG_CACHE_DIR"
			touch "$MINGW_PKG_CACHE_DIR/$pkg"
		fi
	else
		echo "Package dependency $pkg already installed"
	fi

done

case $MINGW_PKG_COMMAND in
	prep)
		prep || exit 1
		;;
	build)
		prep || exit 1
		build || exit 1
		;;
	install)
		prep || exit 1
		build || exit 1
		install || exit 1
		;;
	package)
		prep || exit 1
		build || exit 1
		install || exit 1
		package || exit 1
		;;
	clean)
		clean || exit 1
		;;
	*)
		print_usage
		exit 1
		;;
esac
