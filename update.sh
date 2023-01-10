#!/bin/bash

NERDTOOL="../unRAID-NerdTools"


# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

cd "${NERDTOOL}"

find "${SCRIPTPATH}" -name '*.txz' -print0  | while IFS= read -r -d '' line; do
   echo "$line"
done
