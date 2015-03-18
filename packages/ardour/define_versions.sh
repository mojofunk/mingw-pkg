# 
# this is sourced by build and package, and executed from within build/{osx,linux}_packaging
#

if uname -a | grep arwin >/dev/null 2>&1 ; then
    EXTENDED_RE=-E
else
    EXTENDED_RE=-r
fi

GIT_REV_REGEXP='([0-9][0-9]*)\.([0-9][0-9]*)\-?(rc[0-9]*)?-?([0-9][0-9]*)?(-g([a-f0-9]+))?'

REVISION_FILE="$PKG_BUILD_ROOT/libs/ardour/revision.cc"

major_version=`cut -d'"' -f2 < "$REVISION_FILE" | sed $EXTENDED_RE -e 1d -e "s/$GIT_REV_REGEXP/\1/"`
minor_version=`cut -d'"' -f2 < "$REVISION_FILE" | sed $EXTENDED_RE -e 1d -e "s/$GIT_REV_REGEXP/\2/"`
rc=`cut -d'"' -f2 < "$REVISION_FILE" | sed $EXTENDED_RE -e 1d -e "s/$GIT_REV_REGEXP/\3/"`
r=`cut -d'"' -f2 < "$REVISION_FILE" | sed $EXTENDED_RE -e 1d -e "s/$GIT_REV_REGEXP/\4/"`
commit=`cut -d'"' -f2 < "$REVISION_FILE" | sed $EXTENDED_RE -e 1d -e "s/$GIT_REV_REGEXP/\6/"`

if [ "x$rc" != "x" ] ; then
    revcount=$rc${r:+.$r}
elif [ "x$r" != "x" ] ; then
    revcount=$r
fi

release_version=${major_version}.${minor_version}${revcount:+.$revcount}
