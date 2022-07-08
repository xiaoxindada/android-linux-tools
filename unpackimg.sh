#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh

EROFS_MAGIC_V1="e2e1f5e0" # 0xE0F5E1E2
EXT_MAGIC="53ef" # 0xEF53
SPARSE_MAGIC="3aff26ed" # 0xed26ff3a
SQUASHFS_MAGIC="68737173" # 0x73717368
EXT_OFFSET="1080"
EROFS_OFFSET="1024"
SPARSE_OFFSET="0"
SQUASHFS_OFFSET="0"

rm -rf $OUTDIR
mkdir $OUTDIR

echo ""
read -p "Input partition(Do not to input suffix .img): " species
if [ $(xxd -p -l "2" --skip "$EXT_OFFSET" "${species}.img") = "$EXT_MAGIC" ];then
  echo "detected ${species}.img is ext2/3/4 filesystem"
  echo "extract ${species}.img..."
  python3 $bin/imgextractor.py ${species}.img $OUTDIR
  [ $? != 0 ] && echo "extract ${species}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$SPARSE_OFFSET" "${species}.img") = "$SPARSE_MAGIC" ];then
  echo "Detected ${species}.img is sparse image convert raw image..."
  $bin/simg2img ${species}.img ${species}_raw.img
  [ $? != 0 ] && echo "convert ${species}_raw.img failed!" && exit 1
  mv -f ${species}_raw.img ${species}.img
  echo "extract ${species}.img..."
  python3 $bin/imgextractor.py ${species}.img $OUTDIR
  [ $? != 0 ] && echo "extract ${species}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$EROFS_OFFSET" "${species}.img") = "$EROFS_MAGIC_V1" ];then
  echo "Detected ${species}.img is erofs filesystem"
  echo "extract ${species}.img..."
  $bin/erofsUnpackKt ${species}.img $OUTDIR 
  [ $? != 0 ] && echo "extract ${species}.img failed!" && exit 1
elif [ $(xxd -p -l "4" --skip "$SQUASHFS_OFFSET" "${species}.img") = "$SQUASHFS_MAGIC" ];then
  rm -rf $OUTDIR/${species}
  unsquashfs -q -n -u -d $OUTDIR/${species} ${species}.img
  [ $? != 0 ] && echo "extract ${species}.img failed!" && exit 1
else
  echo "Current image not supported check filesystem!"
  exit 1
fi
