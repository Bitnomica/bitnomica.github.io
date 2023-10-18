#!/usr/bin/env bash

set -e


TARGET="_docs"


function convert(){

  (
    cat <<EOF
---
title: $1
layout: page
toc: true
---
EOF

    asciidoctor -b docbook $2 -o - | \
      iconv -t utf-8 | \
      pandoc -f docbook -t gfm --wrap=none | \
      iconv -f utf-8 
  ) > $3
}

convert "Lifeshare IOS SDK" ../lifeshare-sdk-ios/INTEGRATION.adoc $TARGET/ios.md
convert "Lifeshare Android SDK" ../lifeshare-sdk-android/INTEGRATION.adoc $TARGET/android.md
# convert ../lifeshare-web/INTEGRATION.adoc $TARGET/web_integration.md
cp -a ../lifeshare-web/out/* $TARGET/web_sdk/