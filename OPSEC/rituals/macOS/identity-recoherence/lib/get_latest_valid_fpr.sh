#!/bin/bash
# Usage: get_latest_valid_key "email@example.com"
get_latest_valid_fpr() {
  gpg --list-secret-keys --with-colons "$email" | awk -F: '
    $1 == "sec" && $2 != "r" { t=$5; fpr="" }
    $1 == "fpr" { fpr=$10 }
    fpr && t {
      print t, fpr
      fpr=""; t=""
    }
  ' | sort -nr | head -n1 | cut -d' ' -f2
}