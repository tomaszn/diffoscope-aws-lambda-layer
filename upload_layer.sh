#!/bin/bash

RUNTIME=${1:-python3.6}
TARGET="layer_diffoscope_$RUNTIME.zip"

DESCRIPTION=$(unzip -p $TARGET '*/diffoscope*/METADATA' | grep '^Version')
aws lambda publish-layer-version --layer-name diffoscope --description "$DESCRIPTION" --zip-file fileb://$TARGET --compatible-runtimes $RUNTIME
