# docker-libopenmpt

Build updated [libopenmpt](https://lib.openmpt.org/libopenmpt/) versions inside a docker container, for [WMPlay](https://github.com/silv3rr/chiptune2.js/tree/wmplay) and other javascript web players.

Replace libopenmpt.js file to update (and/or worklet or wasm files).

Original by [DrSnuggles](DrSnuggles), included with [chiptune3](https://github.com/DrSnuggles/chiptune/tree/v3/docker)

## Download

Get files from [Releases](https://github.com/silv3rr/docker-libopenmpt/releases) (created by this [Action](https://github.com/silv3rr/docker-libopenmpt/blob/main/.github/workflows/build.yml))

## Build

To build locally, clone this repo and run build script

Linux: run `make.sh`

Windows: run `make.bat` (tested with [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/))

Compiling takes ~10 minutes on 'modern' 8 core cpu (2025).

There are a few options you can set inside the scripts:

``` shell
VERSION=0.8.3   # libopenmpt version
CORES=8         # use <num> cpu cores to compile, change to match your cpu (default=8)
TARGET=wasm     # audioworkletprocessor, wasm or js (default=wasm)
CLEANUP=0       # set to 1 to remove docker container and images (default=0)
LOCAL_MINI=0    # set to 1 to run brotli locally instead of in container (default=0)
```

## Sources

### Emscripten

Image: [https://hub.docker.com/r/emscripten/emsdk](https://hub.docker.com/r/emscripten/emsdk)

For changes, watch: [https://github.com/emscripten-core/emscripten/blob/main/ChangeLog.md](https://github.com/emscripten-core/emscripten/blob/main/ChangeLog.md)

### Libopenmpt

Releases: [https://lib.openmpt.org/files/libopenmpt/src/](https://lib.openmpt.org/files/libopenmpt/src/)

Autobuilds: https://builds.openmpt.org/builds/auto/libopenmpt/src.makefile/

## Dockerfile

Uses latest emsdk image and `libopenmpt-${VERSION}+release`.

Additional `EXPORTED_FUNCTIONS`, `DEFAULT_LIBRARY_FUNCS_TO_INCLUDE` and `EXPORTED_RUNTIME_METHODS` can be changed in Dockerfile or passed as `--build-args` in build scripts.

## Changelog

empscripten 4.0.15 works with libopenmpt-0.8.3

- 4.0.1x add `HEAP8,HEAPU8,HEAPU32,HEAPF32` to `EXPORTED_RUNTIME_METHODS`
- 4.0.7 add `HEAP8,HEAPU32` to `EXPORTED_FUNCTIONS` (no longer exported by default)
- 3.1.57 update `DEFAULT_LIBRARY_FUNCS_TO_INCLUDE`
- 3.1.5x update `EXPORTED_FUNCTIONS`
- 3.1.21 add `writeAsciiToMemory` to exports, its removed from emscripten (TODO: replace with js function)
