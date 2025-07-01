
# Usage of packages

Download the packages and place them in the extra folder on the flash drive.  If you are doing this from a system currently running this is at `/boot/extra`.

To install the package run `installpkg package_file`

All packages built using scripts from SlackBuilds.org or pulled from official repos unless otherwise specified.



# Usage in un-get (advanced users!)

If not already please install the un-get plugin from https://github.com/ich777/un-get  
Then modify `/boot/config/plugins/un-get/sources.list` and add the following line.  The line is formatted as URL then LABEL so the space is meant to be there.

`>>> https://raw.githubusercontent.com/rufuswilson/unraid-packages/refs/heads/main/slackware64-current/ rufuswilson`

To install a package using un-get run `un-get install package`  
Run just `un-get` to get a list of possible options for the program.
