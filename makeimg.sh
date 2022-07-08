#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

source ./bin.sh
LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR

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

echo "

Pratition size:
_________________

`du -sh $OUTDIR/$partition | awk '{print $1}'`

`du -sm $OUTDIR/$partition | awk '{print $1}' | sed 's/$/&M/'`

`du -sb $OUTDIR/$partition | awk '{print $1}' | sed 's/$/&B/'`
_________________

When repacking, please add 130M to the base size
"

read -p "Input repack partition size: " size

M="$(echo "$size" | sed 's/M//g' | sed 's/m//g')"
G="$(echo "$size" | sed 's/G//g'| sed 's/g//g')"

if [ $(echo "$size" | grep -e 'M' -e 'm') ];then
  ssize=$(($M*1024*1024))
elif [ $(echo "$size" | grep -e 'G' -e 'g') ];then
  ssize=$(($G*1024*1024*1024))
else
  ssize=$(echo "$size" | sed 's/B//g' | sed 's/b//g')
fi

output_image="$OUTDIR/${partition}_new.img"
if [ $partition = "system" ];then
  $bin/mkuserimg_mke2fs.sh "$OUTDIR/$partition/" "$output_image" "ext4" "/$partition" "$ssize" -j "0" -T "1230768000" -C "$OUTDIR/config/${partition}_fs_config" -L "$partition" -I "256" -M "/$partition" -m "0" "$OUTDIR/config/${partition}_file_contexts"
else  
  $bin/mkuserimg_mke2fs.sh "$OUTDIR/$partition/" "$output_image" "ext4" "/$partition" "$ssize" -j "0" -T "1230768000" -C "$OUTDIR/config/${partition}_fs_config" -L "$partition" -I "256" -M "/$partition" -m "0" "$OUTDIR/config/${partition}_file_contexts"
fi

if [ -s $output_image ];then
  echo "Output: $output_image"
else
  echo "Create $output_image failed!"
  exit 1
fi
