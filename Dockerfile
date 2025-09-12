FROM emscripten/emsdk:latest

ARG BASE
ARG FILE
ARG CORES=1
ARG TARGET
ARG EXPORTED_FUNCTIONS="\\['_malloc','_free','stackAlloc','stackSave','stackRestore','UTF8ToString'\\]"
ARG DEFAULT_LIBRARY_FUNCS_TO_INCLUDE="\['stackAlloc','stackSave','stackRestore'\\]"
ARG EXPORTED_RUNTIME_METHODS="\\['writeAsciiToMemory','HEAP8','HEAPU8','HEAPU32','HEAPF32'\\]"

# download libopenmpt and extract
RUN apt-get update -y && apt-get upgrade -y && apt-get install pkg-config brotli -y && \
    wget -q ${BASE}${FILE}.makefile.tar.gz && \
    mkdir libopenmpt && \
    tar xzvf ${FILE}.makefile.tar.gz -C ./libopenmpt --strip-components=1

WORKDIR /src/libopenmpt

# edit make file, build, add tersered polyfills.js and compress .js
RUN sed -i "s/SO_LDFLAGS += .*/SO_LDFLAGS += -s EXPORTED_FUNCTIONS=\\"$EXPORTED_FUNCTIONS\\" -s DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=\\"$DEFAULT_LIBRARY_FUNCS_TO_INCLUDE\\" -s EXPORTED_RUNTIME_METHODS=\\"$EXPORTED_RUNTIME_METHODS\\" /g" build/make/config-emscripten.mk && \
    make -j${CORES} CONFIG=emscripten EMSCRIPTEN_TARGET=${TARGET} && \
    sed -i '1 i\function atob(r){const t="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";let e,o,n,a,c,h,d,f="",i=0;r=r.replace(/[^A-Za-z0-9\+\/\=]/g,"");do{a=t.indexOf(r.charAt(i++)),c=t.indexOf(r.charAt(i++)),h=t.indexOf(r.charAt(i++)),d=t.indexOf(r.charAt(i++)),e=a<<2|c>>4,o=(15&c)<<4|h>>2,n=(3&h)<<6|d,f+=String.fromCharCode(e),64!==h&&(f+=String.fromCharCode(o)),64!==d&&(f+=String.fromCharCode(n))}while(i<r.length);return f}const performance={now:()=>Date.now()};const crypto={getRandomValues(r){for(let t=0;t<r.length;t++)r[t]=256*Math.random()|0}};' bin/libopenmpt.js && \
    brotli -f *.min.js libopenmpt.worklet.js libopenmpt.js libopenmpt.wasm 2>/dev/null || true
