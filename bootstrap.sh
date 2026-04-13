#!/usr/bin/env bash

echo "[INFO]: DOWNLOADING LUA"
curl -L -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz
tar zxf lua-5.5.0.tar.gz
cd lua-5.5.0
echo "[INFO]: MAKING LUA"
make all test
cd ..
echo "[INFO]: BOOTSTRAPPING DONE"
sudo ./lua-5.5.0/src/lua main.lua
