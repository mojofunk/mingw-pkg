# Purpose

The purpose of this project is to be able to build packages of software
compiled for windows with gcc/mingw-w64. Specifically Ardour and related
packages. The only reason it is in a separate repository and not in the
Ardour repository is that I may need the functionality for other software.

This is really a meta packaging system at this point that relies on the
mingw packages being installed on the build host. The "packages" are
just scripts that copy the necessary runtime bits off the build host and
install them into a specified directory.

There are only two platforms "supported" for building packages, Fedora
and MSYS2 but support for other platforms can be added if necessary.

This tool should(but doesn't currently) support building and installing
applications and libraries into the system-wide(MINGW_ROOT) location as
well as packaging them into a specified directory for
testing/distribution.

# Approach

The approach I've taken with the windows packaging which is to install
the app into a prefix and then copy all the library deps and config files
from the system installed packages into the prefix.

A possibly more consistent approach would be to build/configure all the
dependencies with PREFIX and install into bundle/package path and then
also install application into PREFIX.

Another option would be to install binary packages built and maintained
externally(fedora, msys2 etc) using PREFIX as root. One problem with this is
that binary mingw packages in Fedora and MSYS2 aren't split into bin and devel
packages like in native linux Fedora packages. This means instead of specifying
what dll's and files to include/copy into a package, everything would be
installed into package root and we would then need to specify which files to
remove(headers,dll import libs etc).

# Usage

Output from ./mingw-pkg.sh -h
usage: mingw-pkg [-d] [-h] <command> <package>

The commands are:
prep
build
install
package
clean

build a local checkout of ardour in debug config:

ARDOUR_SRC_DIR=../ardour ARDOUR_BRANCH=master ./mingw-pkg.sh -d -v build ardour

or to install to a directory determined in packages/ardour/MINGWPKG based on
ardour version:

ARDOUR_SRC_DIR=../ardour ARDOUR_BRANCH=master ./mingw-pkg.sh -d -v install ardour
