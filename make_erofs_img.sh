#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

usage() {
  echo "$0 <image partition name>"
  exit 1
}

partition="$1"
if [ $# != 1 ];then
  usage
fi

if [ ! -d $OUTDIR/$partition ];then
  echo "$partition src dir not found!"
  echo "Need to use unpackimg.sh extract src"
  exit 1
fi

output_image="$OUTDIR/${partition}_new.img"
rm -rf $output_image
$bin/mkerofsimage.sh "$OUTDIR/${partition}" "$output_image" -m "/${partition}" -C "$OUTDIR/config/${partition}_fs_config" -c "$OUTDIR/config/${partition}_file_contexts" -z "lz4" -T "1230768000"
if [ -s $output_image ]; then
  echo "Create success"
  echo "output: $output_image"
else
  echo "Create ${partition}_new.img failed!"
fi
