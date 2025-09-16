#!/bin/bash -x

VERSION=0.8.3           # libopenmpt version
CORES=8                 # use <num> cpu cores to compile, change to match your cpu (default=8)
CLEANUP=0               # set to 1 to remove docker container and images (default=0)
LOCAL_MINI=0            # run minify/brotli locally(0) or in container(1) (default=0)
DEFAULT_TARGET="wasm"   # audioworkletprocessor, wasm or js (default=wasm)
LOCAL_MINI=0            # set to 1 to run brotli locally instead of in container (default=0)

TARGET=${TARGET:-"$DEFAULT_TARGET"}

# set env var REBUILD=0 to reuse image without (re)compiling, e.g. for CI to use different emscripten target

if [ "${REBUILD:-1}" -eq 1 ];then
  docker build \
    --progress=plain \
    --cache-from emscripten:libopenmpt \
    --build-arg BASE=https://lib.openmpt.org/files/libopenmpt/src/ \
    --build-arg FILE=libopenmpt-${VERSION}+release \
    --build-arg CORES=${CORES} \
    --build-arg TARGET="${TARGET}" \
    --tag emscripten:libopenmpt . || { echo "ERROR: docker build"; exit 1; }
fi

docker rm mpt || true; docker create --name mpt emscripten:libopenmpt

if [ "$TARGET" = "js" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt.js.br
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.mem libopenmpt.js.mem
fi

if [ "$TARGET" = "wasm" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt_wasm.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt_wasm.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm libopenmpt.wasm
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm.br libopenmpt.wasm.br
fi

if [ "$TARGET" = "audioworkletprocessor" ]; then
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.worklet.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt.worklet.js.br
fi


if [ "${CLEANUP:-0}" -eq 1 ]; then
  docker rm mpt
  docker rmi emscripten:libopenmpt
  docker rmi emscripten/emsdk:latest
fi

if [ "${LOCAL_MINI:-0}" -eq 1 ]; then
  for i in libopenmpt.js libopenmpt.wasm; do test -s $i && brotli -f $i; done
fi
