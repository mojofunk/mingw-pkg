# Platform Support

The mingw-pkg system should be able to support building packages for linux and
possibly on mac also in which case it should be renamed.

mingw-pkg should support the use case where it is a project submodule that is
used to build all the dependencies of a project.

# Future

# Meta package system to install dependencies

A platform neutral way of installing dependencies. It detects what the system
is and uses the native package manager to install a package. It does not do any
package management as such.

# split up script

split up the script/s into their component parts for reuse

# Compiler Support

Support for different compilers using a command line option, if a compiler is
not specified then a default will be used.

-c gcc/mingw/clang/vs2013/vs2015 etc

## gcc

This will be the default on linux

## mingw

This will be the default under msys2.

## clang

clang can only be supported currently on linux and mac for c++.

Compiling packages with clang should be as simple as defining CC and CXX?

## msvc

This is probably possible but a lot of work to maintain.

# Package Types

There are four build types of packages

packages using binaries supplied by a distribution
packages built from a source tarball
packages build from a local directory(usually a checkout of an upstream repository or tarball)
packages built from upstream/alternate repositories

-b bin/src/repo/local

With the default being bin but preferring local -> repo -> src -> bin

When the build type of local is specified `MINGW_LOCAL_SRC_DIR` needs to be
defined in the environment specified and by default the package name will be
used as the directory name that is assumed to contain the source for the
package.

Or the package directory could be looked for in the package directory? 

Currently each package directly lists the dependencies, an alternative way
would be to list package sets in a separate file and pass it to the script so
the different packages can be mixed(perhaps not a good idea anyway)

Or there is a dependency list for each build type like `deps.bin`, `deps.src`,
`deps.repo` and `deps.local`?

For packages where we need to patch them or use versions from repositories a
package build type could be passed to select building a build type.

define CCFLAGS and CXXFLAGS if not already defined
