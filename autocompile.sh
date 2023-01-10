#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")

echo "Starting compilations"
find "${SCRIPTPATH}" -name '*.SlackBuild' -print0 | while IFS= read -r -d '' fl; do
   pn=$(echo "${fl}" | sed -e 's#^.*/\([^/]*\)/\([^/]*\)$#\1#g')
   echo "   ${pn}"
   nohup bash "${fl}" 2>&1 1>"${SCRIPTPATH}/${pn}/output.log" &
done

echo "Waiting"
while pgrep -a bash | grep SlackBuild > /dev/null;do
   sleep 1
done

echo "Compilation finished"

exit 0

bash "${SCRIPTPATH}/update.sh"
