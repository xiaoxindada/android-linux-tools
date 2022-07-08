#!/bin/bash

source ./bin.sh
LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR

payload_bin="$1"
toolsdir="payload"

usage() {
  echo "$0 <payload.bin path>"
  exit 1
}

[ $# != 1 ] && usage

if [[ ! -e $payload_bin ]]; then
  if [[ ! -e $toolsdir/payload.bin ]]; then
    echo "payload.bin not found!"
    exit 1
  fi
fi

mkdir -p $OUTDIR
[ ! -e $toolsdir/payload.bin ] && mv $payload_bin $toolsdir/payload.bin

cd $toolsdir
python ./payload.py payload.bin $OUTDIR
[ $? != 0 ] && echo "extract payload.bin failed!" && exit 1
mv payload.bin $LOCALDIR
chmod -R 777 $OUTDIR
