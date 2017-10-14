###############################################################
##
##  Basic environment for Termux
##
##  Should be sourced by any shell's profile.
##
###############################################################

##
## Set the strict file mode creation mask so
## only user with Termux UID can access them.
##
umask 077

##
## Choose home directory
##
## If shell is running under proot as regular user, then
## PROOTED_SHELL will be set so we will not change the
## home directory if root user is emulated (for example with
## fakeroot).
##
if [ "$(id -u)" = "0" ] && [ -z "${PROOTED_SHELL}" ]; then
    export HOME="/data/data/com.termux/files/root"
else
    export HOME="/data/data/com.termux/files/home"
fi

##
## Basic environment variables
##
## Do not touch if you are not know what you are
## doing.
##
export EDITOR="${PREFIX}/bin/nano"
export GOPATH="${HOME}/.go"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export MAIL="${PREFIX}/var/mail/${USER}"
export PATH="${HOME}/.bin:${HOME}/.local/bin:${PREFIX}/bin"
export SDEXT_STORAGE="/data/data/com.termux/files/sdext"
export TERMINFO="${PREFIX}/share/terminfo"
export TERMUX_UID=$(stat -c '%u' "/data/data/com.termux/files")
export TMPDIR="${PREFIX}/tmp"

##
## This variable points to the executable of your
## current shell.
##
## Variable 'SHELL' should be set in profile and
## in *rc file (bash.bashrc or etc).
##
export SHELL=$(readlink "/proc/$$/exe")

##
## Setup private bin directory for user, so it
## can store custom software.
##
if [ ! -e "${HOME}/.local/bin" ]; then
    mkdir -p "${HOME}/.local/bin" > /dev/null 2>&1
fi

##
## Android-related variables
##
## Do not touch if you are not know what you are
## doing.
##
export ANDROID_DATA="${PREFIX}/var/lib/android"
export ANDROID_ROOT="/system"
export BOOTCLASSPATH="/system/framework/core-libart.jar:/system/framework/conscrypt.jar:/system/framework/okhttp.jar:/system/framework/core-junit.jar:/system/framework/bouncycastle.jar:/system/framework/ext.jar:/system/framework/framework.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/system/framework/apache-xml.jar:/system/framework/org.apache.http.legacy.boot.jar:/system/framework/sec_edm.jar:/system/framework/sagearpolicymanager.jar:/system/framework/timakeystore.jar:/system/framework/fipstimakeystore.jar:/system/framework/secocsp.jar:/system/framework/commonimsinterface.jar:/system/framework/imsmanager.jar:/system/framework/sprengine.jar:/system/framework/smartbondingservice.jar:/system/framework/knoxvpnuidtag.jar:/system/framework/sec_sdp_sdk.jar:/system/framework/sec_sdp_hidden_sdk.jar:/system/framework/simageis.jar"

##
## If shell is running under termux-chroot then the
## external storage will be /mnt/emulated/0
##
if [ -e "/.termux-chroot" ]; then
    export EXTERNAL_STORAGE="/mnt/storage/emulated/0"
fi

##
## This is needed for LVM programs to prevent warnings
## about leaked descriptors.
##
LVM_SUPPRESS_FD_WARNINGS="true"
