# Slackbuild: Automated package build scripts.

## autocompile.sh
Script to automatically build and commit changes to the repository.

Every package is contained in their own folders. They must have the following files:
* `update.sh`: script to update the release version
* `requirements.txt`: list of dependencies to compile and build the package
* `build-deps/*.sh`: scripts that are run after the dependencies installation in the slackbuilder container.
* `slackbuild/<packagename>.Slackbuild`: slackbuild script
* `slackbuild/slack-desc`: slackbuild description file
* `slackbuild/doinst.sh`: post installation script to be run

It relies on the [slackbuilder][https://github.com/Lanjelin/slackbuilder] docker image for compiling and building the package. Please have a look at the documentation as there is some customization that is possible.

## pkgdl
Script based on un-get to download package dependencies. It is not clever and you need to tell it which are the dependencies.
To add new repositories please add them to the file `pkgdl-deps\sources.list`.
There is a cache folder `pkgdl-deps\cache` that stores a copy of the downloaded packages and reduce bandwitdh usage.
