#! /bin/bash

echo "Creating debug.bat"
cat > $PKG_INSTALL_DIR/debug.bat << EOF
cd bin
START gdb.exe -iex "dir ../src/gtk2_ardour" -iex "dir ../src/portaudio/src" -iex "set logging overwrite on" -iex "set height 0" -iex "set logging on %UserProfile%\\${PRODUCT_NAME}-debug.log" ${PRODUCT_EXE}
EOF

