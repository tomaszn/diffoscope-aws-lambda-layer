#!/bin/bash

# TODO
# add zipnote to bin/ (zip package)
# add libarchive-tools

RUNTIME=${1:-python3.6}
PKG_DIR=$(mktemp -d ./d.XXXXXX)
trap 'rm -rf "$PKG_DIR"' EXIT
mkdir $PKG_DIR/bin $PKG_DIR/lib
TARGET="layer_diffoscope_$RUNTIME.zip"
rm $TARGET

docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-$RUNTIME \
    sh -c " \
      yum --assumeyes install vim-common && \
      cp /usr/bin/xxd ${PKG_DIR}/bin && \
      yum --assumeyes install libarchive && \
      cp --verbose /usr/lib64/libarchive.so.13 ${PKG_DIR}/lib/libarchive.so && \
      cp --verbose /usr/lib64/liblzo2.so.2 ${PKG_DIR}/lib/ && \
      chown --verbose $(id --user):$(id --group) ${PKG_DIR}/lib/* \
    "
docker run --user $(id --user):$(id --group) --rm -v $(pwd):/foo -w /foo lambci/lambda:build-$RUNTIME \
    sh -c " \
      pip install diffoscope jsbeautifier jsondiff -t ${PKG_DIR}/python --no-cache-dir && \
      cp --verbose ${PKG_DIR}/python/bin/* ${PKG_DIR}/bin/ \
    "

cd $PKG_DIR
zip -r --move ../$TARGET *
cd ..
