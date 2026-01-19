@ECHO OFF

REM :: See build.sh header for info

SET VERSION=0.8.4
SET CORES=8
SET TARGET=wasm
SET /A CLEANUP=0
SET /A LOCAL_MINI=0

(echo %REBUILD% | find "0" >NUL 2>&1) || (
  docker build^
    --progress=plain^
    --cache-from emscripten:libopenmpt^
    --build-arg BASE=https://lib.openmpt.org/files/libopenmpt/src/^
    --build-arg FILE=libopenmpt-%VERSION%+release^
    --build-arg CORES=%CORES%^
    --build-arg TARGET=%TARGET%^
    --tag emscripten:libopenmpt . || ( echo ERROR: docker build & exit /b 1 )
)

docker rm mpt & docker create --name mpt emscripten:libopenmpt

IF "%TARGET%"=="js" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.mem libopenmpt.mem
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt.js.br
)

IF "%TARGET%"=="wasm" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt_wasm.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt_wasm.js.br
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm libopenmpt.wasm
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.wasm.br libopenmpt.wasm.br
)

IF "%TARGET%"=="audioworkletprocessor" (
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js libopenmpt.worklet.js
  docker cp mpt:/src/libopenmpt/bin/libopenmpt.js.br libopenmpt.worklet.js.br
)

IF %CLEANUP% EQU 1 (
  docker rm mpt
  docker rmi emscripten:libopenmpt
  docker rmi emscripten/emsdk:latest
)

IF %LOCAL_MINI% EQU 1 (
  brotli -f *.min.js libopenmpt.js libopenmpt.wasm.js libopenmpt.wasm libopenmpt.worklet.js
)
