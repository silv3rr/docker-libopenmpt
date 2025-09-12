#!/bin/bash

VERSION=0.8.3   # libopenmpt version
CORES=8         # use <num> cpu cores to compile, change to match your cpu (default=8)
TARGET=wasm     # audioworkletprocessor, wasm or js (default=wasm)
CLEANUP=0       # set to 1 to remove docker container and images (default=0)
LOCAL_MINI=0    # run minify/brotli locally(0) or in container(1) (default=0)

# comment 3 lines below to reuse image without (re)compiling, e.g. to use different emscripten target

docker build --build-arg BASE=https://lib.openmpt.org/files/libopenmpt/src/ --build-arg FILE=libopenmpt-${VERSION}+release --build-arg CORES=${CORES} --build-arg TARGET=${TARGET} --tag emscripten:libopenmpt .
docker rm mpt
docker create --name mpt emscripten:libopenmpt

if [ "$TARGET" = "audioworkletprocessor" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.worklet.js
fi

if [ "$TARGET" = "wasm" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm libopenmpt.wasm
fi

if [ "$TARGET" = "js" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.mem libopenmpt.js.mem
fi

if [ "${CLEANUP:-0}" -eq 1 ];then
  docker rm mpt
  docker rmi emscripten:libopenmpt
  docker rmi emscripten/emsdk:latest
fi

if [ "${LOCAL_MINI:-0}" -eq 1 ]; then
  brotli -f ./*.min.js libopenmpt.worklet.js
fi
