#!/bin/bash
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "it is not macOS, aborting."
  exit 1
fi
