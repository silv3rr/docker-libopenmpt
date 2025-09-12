@ECHO OFF

REM :: See build.sh header for info

SET VERSION=0.8.3
SET CORES=8
SET TARGET=wasm
SET /A CLEANUP=0
SET /A LOCAL_MINI=0

docker build --build-arg BASE=https://lib.openmpt.org/files/libopenmpt/src/ --build-arg FILE=libopenmpt-%VERSION%+release --build-arg CORES=%CORES% --build-arg TARGET=%TARGET% --tag emscripten:libopenmpt .
docker rm mpt
docker create --name mpt emscripten:libopenmpt

IF "%TARGET%"=="audioworkletprocessor" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.worklet.js
)

IF "%TARGET%"=="wasm" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm libopenmpt.wasm
)

IF "%TARGET%"=="js" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.mem libopenmpt.mem
)

IF %CLEANUP% EQU 1 (
  docker rm mpt
  docker rmi emscripten:libopenmpt
  docker rmi emscripten/emsdk:latest
)

IF %LOCAL_MINI% EQU 1 (
  brotli -f *.min.js libopenmpt.worklet.js
)
