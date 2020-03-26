#!/bin/bash

#
#       This script removes the open source disclaimer
#       of Xen Orchestra 5
#
#       how to run:
#
#       place it in the directory where you ran the
#       git clone ... xen-orchestra
#

myinit() {

        if ! [ -d "xen-orchestra" ]; then

                echo
                echo "You are not in the parent directory of the xen-orchestra checkout"
                echo "this script must be run from there"
                echo
                exit 1

        fi

        if ! [ -r "$file" ]; then

                echo 
                echo "target file '$file' can not be found, aborting"
                echo
                exit 1

        fi
}

# 
# remove the following code fragment
#
#   if (+process.env.XOA_PLAN === 5) {
#     this.displayOpenSourceDisclaimer()
#   }
#

patch_file() {

        mv "$file" "$file.bak"
        awk '
                /\+process.env.XOA_PLAN[ \t]+=+[ \t]+5/         { start_patch=1 ; next }
                /this\.displayOpenSourceDisclaimer/             { next }
                start_patch == 1 && /\}/                        { start_patch=0 ; next }

                1
                ' "$file.bak" >"$file"
        }

main() {

        myinit
        systemctl stop xo-server
        patch_file
        cd xen-orchestra
        yarn build
        cd -
        systemctl start xo-server

}

export file="xen-orchestra/packages/xo-web/src/xo-app/index.js"
main
