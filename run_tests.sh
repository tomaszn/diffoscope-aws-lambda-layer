#!/bin/sh
set -x
RUNTIME=${1:-python3.6}

rm -r opt
mkdir opt
cd opt
unzip ../layer_diffoscope_$RUNTIME.zip
ldd bin/* || true
ldd lib/* || true
cd ..
ls -l
docker run -e MAGIC=/usr/share/misc/magic:/opt/magic -e LD_PRELOAD=/opt/lib/libarchive.so -e DOCKER_LAMBDA_DEBUG=1 --rm -v "$PWD":/var/task:ro,delegated -v "$PWD"/opt/:/opt:ro,delegated lambci/lambda:$RUNTIME tests.run 2> /tmp/test_results
cat /tmp/test_results
grep '^OK$' /tmp/test_results
