#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------
cd ..

jazzy \
  --clean \
  --swift-version 2.2 -o ./ \
  --readme README.md \
  --author 'Hotwire' \
  -u 'www.hotwire.com' \
  --github_url 'https://github.com/HotwireDotCom' \
  --output Documentation \
  --xcodebuild-arguments -scheme,APIResponseSpoofer \
  --module APIResponseSpoofer
