#!/usr/bin/env bash
set -e
for c in git ansible make python3; do command -v $c && echo "$c OK"; done
