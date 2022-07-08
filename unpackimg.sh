#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

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

EROFS_MAGIC_V1="e2e1f5e0" # 0xE0F5E1E2
EXT_MAGIC="53ef"          # 0xEF53
SPARSE_MAGIC="3aff26ed"   # 0xed26ff3a
SQUASHFS_MAGIC="68737173" # 0x73717368
EXT_OFFSET="1080"
EROFS_OFFSET="1024"
SPARSE_OFFSET="0"
SQUASHFS_OFFSET="0"

mkdir -p $OUTDIR
rm -rf $OUTDIR/$partition

[ ! -f ${partition}.img ] && echo "${partition}.img not found!" && exit 1
if [ $(xxd -p -l "2" --skip "$EXT_OFFSET" "${partition}.img") = "$EXT_MAGIC" ]; then
  echo "detected ${partition}.img is ext2/3/4 filesystem"
  echo "extract ${partition}.img..."
  python3 $bin/imgextractor.py ${partition}.img $OUTDIR
  [ $? != 0 ] && echo "extract ${partition}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$SPARSE_OFFSET" "${partition}.img") = "$SPARSE_MAGIC" ]; then
  echo "Detected ${partition}.img is sparse image convert raw image..."
  $bin/simg2img ${partition}.img ${partition}_raw.img
  [ $? != 0 ] && echo "convert ${partition}_raw.img failed!" && exit 1
  mv -f ${partition}_raw.img ${partition}.img
  echo "extract ${partition}.img..."
  python3 $bin/imgextractor.py ${partition}.img $OUTDIR
  [ $? != 0 ] && echo "extract ${partition}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$EROFS_OFFSET" "${partition}.img") = "$EROFS_MAGIC_V1" ]; then
  echo "Detected ${partition}.img is erofs filesystem"
  echo "extract ${partition}.img..."
  $bin/erofsUnpackKt ${partition}.img $OUTDIR
  [ $? != 0 ] && echo "extract ${partition}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$SQUASHFS_OFFSET" "${partition}.img") = "$SQUASHFS_MAGIC" ]; then
  rm -rf $OUTDIR/${partition}
  unsquashfs -q -n -u -d $OUTDIR/${partition} ${partition}.img
  [ $? != 0 ] && echo "extract ${partition}.img failed!" && exit 1
else
  echo "Current image not supported check filesystem!"
  exit 1
fi
