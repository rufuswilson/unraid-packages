#!/bin/bash

NERDTOOL="../unRAID-NerdTools"
NERDPKG="${NERDTOOL}/packages/"

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")

cd "${SCRIPTPATH}/${NERDPKG}"

git pull

find "${SCRIPTPATH}" -name '*.txz' -print0 | while IFS= read -r -d '' fl; do
   fn=$(echo "${fl}" | sed -e 's#^.*/\([^/]*\)$#\1#g')
   pn=$(echo "${fn}" | sed -e 's#^\(.*\)\-\([^\-]*\)\-\([^\-]*\).txz$#\1#g')
   vn=$(echo "${fn}" | sed -e 's#^\(.*\)\-\([^\-]*\)\-\([^\-]*\).txz$#\2#g')
   pt=$(echo "${fn}" | sed -e 's#^\(.*\)\-\([^\-]*\)\-\([^\-]*\).txz$#\3#g')
   echo "Processing ${pn} ${vn} ${pt}"
   if [[ -n $(find . -name "${fn}") ]] ; then
      echo "   already up-to-date"
      continue
   else
      find . -name "${pn}*{pt}.txz" -exec rm {} \;
      for D in */; do
         echo "   copying to ${D}"
         cp "${fl}" "${SCRIPTPATH}/${NERDPKG}${D}"
         git add "${SCRIPTPATH}/${NERDPKG}${D}"
      done
   fi
   git commit -m "Updated ${pn} to ${vn} for ${pt}"
done

git push

