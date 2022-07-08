#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh
images_dir="$LOCALDIR/images"

rm -rf $LOCALDIR/${species}.img
read -p "Input partinion(do not to input suffix .img): " species
$bin/mkerofsimage.sh "$OUTDIR/${species}" "$OUTDIR/${species}.img" -m "/${species}" -C "$OUTDIR/config/${species}_fs_config" -c "$OUTDIR/config/${species}_file_contexts" -z "lz4" -T "1230768000"
if [ -s $OUTDIR/${species}.img ];then
  echo "Create success"
  echo "output: $OUTDIR"
  mkdir -p 
  mv -f $OUTDIR/${species}.img $images_dir
  chmod 777 -R $images_dir
else
  echo "Create ${species}.img failed!"
fi

