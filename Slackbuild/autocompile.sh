#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")
SCRIPTNAME=$(basename -- "${SCRIPT}")

# Update repositories
bash "${SCRIPTPATH}/pkgdl" update

echo "Starting compilations"
for d in ${SCRIPTPATH}/*/ ; do
   d="$(echo "${d}" | sed -e 's#/$##')"
   if [ ! -d "${d}/slackbuild" ] ; then
      continue
   fi
   PACKAGE=$(basename -- "${d}")
   
   echo "  ${PACKAGE}"

   bash "${d}/update.sh" > "${d}/update.log"
   if [ "$?" != 0 ]; then
      echo "     Already up to date"
      continue
   fi

   echo "     Preparing subfolders"
   if [ ! -d "${d}/build-deps" ] ; then
      mkdir "${d}/build-deps"
   else
      rm "${d}/build-deps/"*.* 2>/dev/null
   fi
   if [ ! -d "${d}/output" ] ; then
      mkdir "${d}/output"
   else
      rm "${d}/output/"*.{log} 2>/dev/null
   fi

   echo "     Retrieving dependencies"
   DEPS="$(cat "${d}/requirements.txt" | tr -s '\n' ' ')"
   bash "${SCRIPTPATH}/pkgdl" download "${d}/build-deps" ${DEPS} > "${d}/output/deps.log"

   echo "     Getting version"
   VERSIONNEW=$(cat "${d}/slackbuild/version" | tr -d '\n')

   echo "     Building package"
   docker run \
      --rm --privileged \
      --name SBR_${PACKAGE}_${VERSIONNEW} \
      --mount type=bind,src=${d}/build-deps,dst=/build-deps \
      --mount type=bind,src=${d}/slackbuild,dst=/slackbuild \
      --mount type=bind,src=${d}/output,dst=/output \
      -e OUTPUT=/output \
      -e TMP=/tmp \
      -it --entrypoint /bin/bash \
      ghcr.io/lanjelin/slackbuilder:latest \
      > "${d}/output/compile.log"

   # if [ ! -d "${SCRIPTPATH}/../slackware64-current/${SCRIPTNAME}" ] ; then
   #    mkdir "${SCRIPTPATH}/../slackware64-current/${SCRIPTNAME}"
   # fi

   # echo "     Comitting changes"
   # git add "${d}/slackbuild/version"
   # git add "${SCRIPTPATH}/../slackware64-current/${SCRIPTNAME}"
   # git commit -m "updated version for ${PACKAGE}"
done

echo "Compilation finished"
