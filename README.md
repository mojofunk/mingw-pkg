The purpose of this project is to be able to build packages of software
compiled for windows with gcc/mingw-w64.

This is really a meta packaging system at this point that relies on some
mingw packages being installed on the build host.

There are only two platforms "supported" for building packages, Fedora
and MSYS2 but support for other platforms can be added if necessary.

This tool needs to support building and installing applications and
libraries into the system-wide(MINGW_ROOT) location as well as 
packaging them into a specified directory for testing/distribution.

The system will initially be implemented with shell script/s

[ Approach ]

The approach I've taken with the windows packaging which is to install
the app into a prefix and then copy all the library deps and config files
from the system installed packages into the prefix.

A possibly more consistent approach would be to build/configure all the
dependencies with PREFIX and install into bundle/package path and then
also install application into PREFIX.

Another option would be to install binary packages built and maintained
externally(fedora, msys2 etc) using PREFIX as root.

[ Usage ]

build project ardour on fedora-19 in debug config 

./mingw-pkg.sh -d build ardour

or to install

./mingw-pkg.sh -d install ardour
