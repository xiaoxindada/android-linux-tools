#!/bin/bash
source ./bin
payload="$1"
$toolsdir="payload"
mv $payload $tools_dir

usage() {
  echo "$0 <payload.bin path>"
  exit 1
}

[ $# != 1 ] && usage
[ ! -e $payload ] && "payload.bin not found!" && exit 1

cd $toolsdir
python ./payload.py $payload $OUTDIR
[ $? != 0 ] && "extract payload.bin failed!" && exit 1

