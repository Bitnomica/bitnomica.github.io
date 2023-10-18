#!/usr/bin/env bash

set -e


TARGET="_docs"


function convert(){

  (
    cat <<EOF
---
layout: page
toc: true
---
EOF

    asciidoctor -b docbook $1 -o - | \
      iconv -t utf-8 | \
      pandoc -f docbook -t gfm --wrap=none | \
      iconv -f utf-8 
  ) > $2
}

convert ../lifeshare-sdk-ios/INTEGRATION.adoc $TARGET/ios_integration.md
convert ../lifeshare-sdk-android/INTEGRATION.adoc $TARGET/android_integration.md
# convert ../lifeshare-web/INTEGRATION.adoc $TARGET/web_integration.md
cp -a ../lifeshare-web/out/* $TARGET/web_sdk/