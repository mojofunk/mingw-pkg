The purpose of this project is to be able to build installable packages
windows for Ardour, Alta and other software and share the packaging 
infrastructure.

The system will initially be implemented with shell script/s

[ Approach ]

The approach I've taken with the windows packaging which is to install
the app into a prefix and then copy all the library deps and config files
from the system installed packages into the prefix.

A possibly more consistent approach would be to build/configure all the
dependencies with PREFIX and install into bundle/package path and then
also install application into PREFIX.

Another option is to rely on binary packages built and maintained
externally(fedora, msys2 etc) and then install these packages using PREFIX
as root.

[ Usage ]

build project ardour on fedora-19 in debug config 

./mingw-pkg.sh -d build ardour

or to install

./mingw-pkg.sh -d install ardour
