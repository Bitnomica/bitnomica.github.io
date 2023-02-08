#!/usr/bin/env bash

set -e

HEADER="---
layout: page
toc: true
---
"

TARGET="_docs"

(echo "$HEADER" ; cat ../lifeshare-sdk-ios/INTEGRATION.adoc) > $TARGET/ios_integration.adoc
(echo "$HEADER" ; cat ../lifeshare-sdk-android/INTEGRATION.adoc) > $TARGET/android_integration.adoc
(echo "$HEADER" ; cat ../lifeshare-web/INTEGRATION.adoc) > $TARGET/web_integration.adoc
# cp ../lifeshare-web/INTEGRATION.adoc $TARGET/web_integration.adoc
