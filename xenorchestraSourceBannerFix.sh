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

# commented out this section about confirming you're in the right directory, cause our new version doesn't care.
#        if ! [ -d "xo-web" ]; then
#
#                echo
#                echo "You are not in the parent directory of the xo-web checkout"
#                echo "this script must be run from there"
#                echo
#                exit 1
#
#        fi

        if ! [ -r "$file" ]; then

                echo 
                echo "target file '$file' can not be found, aborting"
                echo
                exit 1

        fi
}

# 
# remove the following 2 code fragments
#
#   ...
# 
#   if (+process.env.XOA_PLAN === 5) {
#     this.displayOpenSourceDisclaimer()
#   }
#
#   ...
#
#    {plan === 'Community' && !this.state.dismissedSourceBanner && (
#       <div className='alert alert-danger mb-0'>
#         <a
#           href='https://xen-orchestra.com/#!/xoa?pk_campaign=xo_source_banner'
#           rel='noopener noreferrer'
#           target='_blank'
#         >
#           {_('disclaimerText3')}
#         </a>
#         <button className='close' onClick={this.dismissSourceBanner}>
#           &times;
#         </button>
#       </div>
#      )}






patch_file() {

        mv "$file" "$file.bak"
        awk '
                /\+process.env.XOA_PLAN[ \t]+=+[ \t]+5/         { start_patch=1 ; next }
                /this\.displayOpenSourceDisclaimer/             { next }
                start_patch == 1 && /\}/                        { start_patch=0 ; next }

                /plan === .Community. /                         { start_patch2=1 ; next }
                /this.dismissSourceBanner/                      { start_patch2=2 ; next }
                start_patch2==2 && /\)\}/                       { start_patch2=0 ; next }
                start_patch2>0                                  {next}

                1
                ' "$file.bak" >"$file"
        }

main() {

        myinit
        systemctl stop xo-server
        patch_file
        cd $buildfolder
        # this switches to the latest buildfolder, becuase xen-updater keeps 3 versions
        cd  "$(\ls -1dt ./*xen*/ | head -n 1)"
        yarn
        yarn build
        systemctl start xo-server

}
# We're changing this path to be more compliant with the way xen-orcehstra-installer-updater does versionining
export file="/opt/xo/xo-web/src/xo-app/index.js"
export buildfolder="/opt/xo/xo-builds/"
main
