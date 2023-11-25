#!/bin/sh

echo "sha256-$(curl -L "$1" | sha256sum | cut -d ' ' -f 1 | xxd -r -p | base64)"
