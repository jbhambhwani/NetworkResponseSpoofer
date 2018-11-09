#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------
cd ..

jazzy \
  --clean \
  --readme README.md \
  --author 'Hotwire' \
  --author_url 'www.hotwire.com' \
  --github_url 'https://github.com/HotwireDotCom/NetworkResponseSpoofer.git' \
  --output Documentation \
  --xcodebuild-arguments -scheme,NetworkResponseSpoofer \
  --module NetworkResponseSpoofer
