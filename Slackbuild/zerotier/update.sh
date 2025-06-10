#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")
SCRIPTNAME=$(basename -- "${SCRIPT}")

VERSIONNEW=$(curl --silent "https://api.github.com/repos/zerotier/ZeroTierOne/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ ! -f "${SCRIPTPATH}/slackbuild/version" ] ; then
	echo -n "notexist" > "${SCRIPTPATH}/slackbuild/version"
fi
VERSIONOLD=$(cat "${SCRIPTPATH}/slackbuild/version" | tr -d '\n')

if [[ "${VERSIONNEW}" == "${VERSIONOLD}" ]] ; then
	echo "Already up to date: ${VERSIONNEW}"
	exit 1
fi

echo "New version: ${VERSIONNEW}"
echo -n "${VERSIONNEW}">"${SCRIPTPATH}/slackbuild/version"

exit 0