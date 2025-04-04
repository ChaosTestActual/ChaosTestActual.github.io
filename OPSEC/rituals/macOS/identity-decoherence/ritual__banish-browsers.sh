#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH BROWSERS: "

echo "$prefix __INITIATED__."

echo "$prefix Deleting Safari data..."
rm -rf ~/Library/Safari
rm -rf ~/Library/Caches/com.apple.Safari
rm -rf ~/Library/WebKit/com.apple.Safari

echo "$prefix Deleting Chrome data..."
rm -rf ~/Library/Application\ Support/Google/Chrome
rm -rf ~/Library/Caches/Google/Chrome

echo "$prefix __COMPLETE__."