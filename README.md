# docker-libopenmpt

Build updated libopenmpt versions inside a docker container, for [WMPlay](https://github.com/silv3rr/chiptune2.js/tree/wmplay) and other javascript web players.

After building just replace the libopenmpt.js file to update (and/or worklet or wasm files).

Original by [DrSnuggles](DrSnuggles), included with [chiptune3](https://github.com/DrSnuggles/chiptune/tree/v3/docker)

## Build

Github: [Download](https://github.com/silv3rr/docker-libopenmpt/releases) (created by [Action](https://github.com/silv3rr/docker-libopenmpt/blob/main/.github/workflows/docker.yml))

Linux: run `make.sh`

Windows: run `make.bat` (e.g. Docker Desktop)

Compiling takes ~10 minutes on 'modern' 8 core cpu (2025).

There are a few options you can set inside the scripts:

``` shell
VERSION=0.8.3   # libopenmpt version
CORES=8         # use <num> cpu cores to compile, change to match your cpu (default=8)
TARGET=wasm     # audioworkletprocessor, wasm or js (default=wasm)
CLEANUP=0       # set to 1 to remove docker container and images (default=0)
LOCAL_MINI=0    # run minify/brotli locally(0) or in container(1) (default=0)
```

## Emscripten

For changes, watch: [https://github.com/emscripten-core/emscripten/blob/main/ChangeLog.md](https://github.com/emscripten-core/emscripten/blob/main/ChangeLog.md)

Releases: https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-0.7.4+release.makefile.tar.gz

Autobuilds:

- https://builds.openmpt.org/builds/auto/libopenmpt/src.makefile/0.7.5-pre.0/libopenmpt-0.7.5-pre.0+r20329.makefile.tar.gz
- https://builds.openmpt.org/builds/auto/libopenmpt/src.makefile/0.8.0-pre.4/libopenmpt-0.8.0-pre.4+r20328.makefile.tar.gz

### Dockerfile

Additional `EXPORTED_FUNCTIONS`, `DEFAULT_LIBRARY_FUNCS_TO_INCLUDE` and `EXPORTED_RUNTIME_METHODS` can be changed in Dockerfile or passed as `--build-args` in build scripts.

#### Changelog

- 3.1.21 `writeAsciiToMemory` removed, added to exports (TODO: replace)
- 3.1.5x update `EXPORTED_FUNCTIONS`
- 3.1.57 update `DEFAULT_LIBRARY_FUNCS_TO_INCLUDE`
- 4.0.7 no `HEAP8,HEAPU32` export by default, add to `EXPORTED_FUNCTIONS`
- 4.0.1x add `HEAP8,HEAPU8,HEAPU32,HEAPF32` to `EXPORTED_RUNTIME_METHODS`
- 4.0.15 works with libopenmpt-0.8.3

## Minifying

This can be done at any time in a "standalone" container, separately from build.

Brotli compression:

`docker run --rm --workdir /build -v "$PWD:/build" alpine:latest sh -c 'apk add brotli && brotli -f *.min.js libopenmpt.worklet.js libopenmpt.js libopenmpt.wasm 2>/dev/null'`

(the build scripts also do this)

_Minify chiptune3.js:_

_`docker run --rm --workdir /build -v "$PWD:/build" node:latest sh -c 'npm install terser; npm run minify; rm -rf node_modules package-lock.json'`_
