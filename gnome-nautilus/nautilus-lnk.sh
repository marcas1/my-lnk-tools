#!/bin/bash

# a bash script to read Netpath of a windows share shortcut .mnk
# and open it in another nautilus window
# Marc'AS'1 2020/10/21
# TODO : more checks for injection prevention, test liblnk-utils package is installed

# smb://server1/share1/Utilitaires/Java%20-%20Raccourci.lnk
# /run/user/1002/gvfs/smb-share:server=server1,share=share1/Utilitaires/Java - Raccourci.lnk'

LNKCMD="/usr/bin/lnkinfo"
# translate %20 to space 
SMBLNK="$(echo $1 | sed 's/%20/ /g')"
GVFSROOTPATH="/run/user/$UID/gvfs"

# with %f nautilus send gvfs absolute path, with copy file it"s %u usr smb://...
# https://askubuntu.com/questions/783292/what-do-the-various-percent-parameters-in-context-menu-actions-or-desktop-f
if [[ $SMBLNK == "smb://"* ]]
then
    LNK=`echo "$SMBLNK" |sed 's/smb:\/\/\([^/]*\)\//smb-share:server=\1,share=/'`
    LNK="${GVFSROOTPATH}/${LNK}"
else
    LNK=$SMBLNK
fi
    
NETPATH=$($LNKCMD  "$LNK" | grep "Network path" | cut -f2 -d:)
# Mount this share
SERVR=$(echo $NETPATH | cut -f3 -d\\)
SHARE=$(echo $NETPATH | cut -f4 -d\\)
gio mount "smb://$SERVR/$SHARE"

# lowercase server and share to produc absolute path in gvfs
GVFSRELPATH=$(echo $NETPATH |tr A-Z a-z | sed 's/\\/\//g' | sed 's/ *\/\/\([^/]*\)\//smb-share:server=\1,share=/')
nautilus "${GVFSROOTPATH}/${GVFSRELPATH}"


