#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")
SCRIPTNAME=$(basename -- "${SCRIPT}")

rm "${SCRIPTPATH}/"*.log 2>&1 >/dev/null

date +"%Y-%m-%d %T"

echo "Update current repository" | tee -a "${SCRIPTPATH}/git.log"
git pull >> "${SCRIPTPATH}/git.log"

echo "Update repositories"
bash "${SCRIPTPATH}/pkgdl" update 2>&1 > "${SCRIPTPATH}/pkgdl.log"

echo "Update slackbuilder docker image"
docker pull ghcr.io/lanjelin/slackbuilder:latest > "${SCRIPTPATH}/docker.log"

hasUpdate=0
echo "Starting compilations"
for d in ${SCRIPTPATH}/*/ ; do
   d="$(echo "${d}" | sed -e 's#/$##')"
   if [[ ! -d "${d}/slackbuild" ]] ; then
      continue
   fi
   PACKAGE=$(basename -- "${d}")

   echo "  ${PACKAGE}"
   cd "${d}"

   if [[ ! -d "logs" ]] ; then
      mkdir "logs"
   else
      rm -f "logs/"*.* 2>&1 1>/dev/null
   fi

   echo "     Checking version"
   bash "update.sh" > "logs/update.log"
   if [[ "$?" != 0 ]]; then
      echo "          Already up to date"
      continue
   fi

   echo "     Preparing subfolders"
   if [[ ! -d "build-deps" ]] ; then
      mkdir "build-deps"
   else
      rm -f "build-deps/"*.{tbz,tgz,tlz,txz} 2>&1 1>/dev/null
   fi
   if [[ ! -d "output" ]] ; then
      mkdir "output"
   else
      rm -f "output/"*.* 2>&1 >/dev/null
   fi

   echo "     Retrieving dependencies"
   DEPS="$(cat "requirements.txt" | tr -s '\n' ' ')"
   bash "${SCRIPTPATH}/pkgdl" download "build-deps" ${DEPS} > "logs/deps.log"
   if [[ "$?" != 0 ]]; then
      echo "          xxx failed"
      exit 1
   fi

   echo "     Getting version"
   VERSIONNEW=$(cat "slackbuild/version" | tr -d '\n')

   echo "     Building package"
   docker run \
      --rm \
      --name SBR_${PACKAGE}_${VERSIONNEW} \
      --mount type=bind,src="${d}/build-deps",dst=/build-deps \
      --mount type=bind,src="${d}/slackbuild",dst=/slackbuild \
      --mount type=bind,src="${d}/output",dst=/output \
      --mount type=bind,src="${d}/logs",dst=/logs \
      -e OUTPUT=/output \
      -e TMP=/tmp \
      -e VERBOSITY=1 \
      ghcr.io/lanjelin/slackbuilder:latest
      # -it --entrypoint /bin/bash \

   if [[ -z "$( ls -A "output/" )" ]]; then
      echo "          xx Failed to build"
      continue
   fi

   echo "     Copying package to repo"
   if [[ ! -d "${SCRIPTPATH}/../slackware64-current" ]] ; then
      mkdir "${SCRIPTPATH}/../slackware64-current"
   fi
   if [[ ! -d "${SCRIPTPATH}/../slackware64-current/${PACKAGE}" ]] ; then
      mkdir "${SCRIPTPATH}/../slackware64-current/${PACKAGE}"
   fi
   rm "${SCRIPTPATH}/../slackware64-current/${PACKAGE}/"*.{tbz,tgz,tlz,txz} 2>/dev/null
   cp "output/"*${VERSIONNEW}*.{tbz,tgz,tlz,txz} "${SCRIPTPATH}/../slackware64-current/${PACKAGE}/"

   echo "     Staging changes"
   git add "slackbuild/version"
   git add -A "${SCRIPTPATH}/../slackware64-current/${PACKAGE}/"
   hasUpdate=1
done

if [[ ${hasUpdate} -eq 1 ]] ; then
   cd "${SCRIPTPATH}/../slackware64-current"

   bash buildlist.sh ./

   echo '--------------------------' >> "${SCRIPTPATH}/git.log"
   echo "Comitting changes" | tee -a "${SCRIPTPATH}/git.log"
   git add FILE_LIST CHECKSUMS.md5
   git commit -m "Packages updated" | tee -a "${SCRIPTPATH}/git.log"

   echo '--------------------------' >> "${SCRIPTPATH}/git.log"
   echo "Pushing changes" | tee -a "${SCRIPTPATH}/git.log"
   git push | tee -a "${SCRIPTPATH}/git.log"
fi

echo "Compilation finished"
date +"%Y-%m-%d %T"

