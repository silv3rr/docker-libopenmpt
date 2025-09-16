
# Minifying

Besides installing and running `brotli` and `npm` this can also be done at any time in a "standalone" container, separately from build.

Brotli compression:

`docker run --rm --workdir /build -v "$PWD:/build" alpine:latest sh -c 'apk add brotli && for i in libopenmpt.js libopenmpt_wasm.js libopenmpt.wasm libopenmpt.worklet.js; do test -s $i && brotli -f $i; done'`

(the build scripts also do this)

_Minify chiptune3.js:_

_`docker run --rm --workdir /build -v "$PWD:/build" node:latest sh -c 'npm install terser; npm run minify; rm -rf node_modules package-lock.json'`_
