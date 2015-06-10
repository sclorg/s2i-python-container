# IMPORTANT: Do not add more content to this file unless you know what you are
#            doing. This file is sourced everytime the shell session is opened.
#
# Set current user in nss_wrapper
export USER_ID=$(id -u)
envsubst < ${HOME}/passwd.template > ${HOME}/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${HOME}/passwd
export NSS_WRAPPER_GROUP=/etc/group

# This will make scl collection binaries work out of box.
unset BASH_ENV
source scl_source enable python33

