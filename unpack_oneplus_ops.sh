#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

Usage() {
  cat <<EOT
Usage:
$0 <Ops File Path>
EOT
}

if [ $# -lt 1 ]; then
  Usage
  exit 1
fi

toolsdir="$LOCALDIR/oppo_decrypt"
ops_extract_tool="$toolsdir/opscrypto.py"
ops_out_dir="$toolsdir/extract"
ops_file="$1"

rm -rf $ops_out_dir
[ ! -f $ops_file ] && echo "$ops_file not found!" && exit 1

mv $ops_file $toolsdir
cd $toolsdir
printf "Decrypting ops & extracing...\n"
python3 "${ops_extract_tool}" decrypt "${ops_file}"
[ ! -d "$ops_out_dir" ] && echo "extract ops failed!" && exit 1
if [ $(ls $ops_out_dir 2>&1 | wc -l) != 0 ]; then
  rm -rf $LOCALDIR/ops_out
  mv $ops_out_dir $LOCALDIR/ops_out
  mv $ops_file $LOCALDIR
  chmod -R 777 $LOCALDIR/ops_out
  echo "Final_out: $LOCALDIR/ops_out"
  exit 0
else
  echo "extract ops failed!"
  mv $ops_file $LOCALDIR
  exit 1
fi
