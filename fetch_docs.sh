#!/usr/bin/env bash

set -e

HEADER="---
layout: page
toc: true
---
"

TARGET="_docs"

# (echo "$HEADER" ; cat ../lifeshare-sdk-ios/INTEGRATION.adoc) > $TARGET/ios_integration.adoc
# (echo "$HEADER" ; cat ../lifeshare-sdk-android/INTEGRATION.adoc) > $TARGET/android_integration.adoc
# (echo "$HEADER" ; cat ../lifeshare-web/INTEGRATION.adoc) > $TARGET/web_integration.adoc
# cp ../lifeshare-web/INTEGRATION.adoc $TARGET/web_integration.adoc

function convert(){

    (
        echo "---
layout: page
toc: true
"
    asciidoctor -b docbook $1 -o - | \
      iconv -t utf-8 | \
      pandoc -f docbook -t gfm --wrap=none | \
      iconv -f utf-8 
    )> $2
}

convert ../lifeshare-sdk-ios/INTEGRATION.adoc $TARGET/ios_integration.md
convert ../lifeshare-sdk-android/INTEGRATION.adoc $TARGET/android_integration.md
# convert ../lifeshare-web/INTEGRATION.adoc $TARGET/web_integration.md
cp -a ../lifeshare-web/out/* _docs/web_sdk/