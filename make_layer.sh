#!/bin/bash

# TODO add zipnote to bin/ (zip package)
# TODO add libarchive-tools
# jsondiff: would crash on Chrome extensions (manifest.json is not a valid JSON)

RUNTIME=${1:-python3.6}
PKG_DIR=$(mktemp -d ./d.XXXXXX)
trap 'rm -rf "$PKG_DIR"' EXIT
mkdir $PKG_DIR/bin $PKG_DIR/lib
TARGET="layer_diffoscope_$RUNTIME.zip"
rm $TARGET

docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-$RUNTIME \
    sh -c " \
      cd ${PKG_DIR} && \
      yum --assumeyes install vim-common && \
      cp --verbose /usr/bin/xxd bin/ && \
      yum --assumeyes install libarchive && \
      cp --verbose /usr/lib64/libarchive.so.13 lib/libarchive.so && \
      cp --verbose /usr/lib64/libarchive.so.13 lib/libarchive.so.13 && \
      cp --verbose /usr/lib64/liblzo2.so.2 lib/ && \
      cp --verbose /usr/lib64/libmagic.so.1 lib/ && \
      chown --verbose $(id --user):$(id --group) lib/* \
    "
docker run --user $(id --user):$(id --group) --rm -v $(pwd):/foo -w /foo lambci/lambda:build-$RUNTIME \
    sh -c " \
      pip install diffoscope jsbeautifier -t ${PKG_DIR}/python --no-cache-dir && \
      cp --verbose ${PKG_DIR}/python/bin/* ${PKG_DIR}/bin/ \
    "

cd $PKG_DIR
zip -r --move ../$TARGET *
cd ..
