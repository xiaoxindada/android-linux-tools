#!/bin/bash

LOCALDIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd $LOCALDIR

ozip="$1"
toolsdir="$LOCALDIR/oppo_ozip_decrypt"
ozip_decrypt_tool="$toolsdir/ozipdecrypt.py"

usage() {
    echo "$0 <ozip path>"
    exit 1
}

[ $# != 1 ] && usage
[ ! -f $ozip ] && "$ozip not found!" && exit 1

$ozip_decrypt_tool "$ozip"
