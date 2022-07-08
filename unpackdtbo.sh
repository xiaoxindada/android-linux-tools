#!/bin/bash

# Copyright (C) 2021 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh

if [ ! -e $LOCALDIR/dtbo.img ];then
  echo "dtbo.img not found!"
  exit 1
fi
dtc="dtb_tools/dtc"
mkdtimg_tool="dtb_tools/mkdtboimg.py"
dtbodir="$LOCALDIR/dtbo"

rm -rf $dtbodir
mkdir -p $dtbodir/dtbo_files
mkdir -p $dtbodir/dts_files

echo "正在解压dtbo.img"
$mkdtimg_tool dump "$LOCALDIR/dtbo.img" -b "$dtbodir/dtbo_files/dtbo" > $dtbodir/dtbo_imageinfo.txt

dtbo_files_name=$(ls $dtbodir/dtbo_files)
for dtbo_files in $dtbo_files_name ;do
  dts_files=$(echo "$dtbo_files" | sed 's/dtbo/dts/g')
  echo "Decompile $dtbo_files to $dts_files"
  $dtc -@ -I "dtb" -O "dts" "$dtbodir/dtbo_files/$dtbo_files" -o "$dtbodir/dts_files/$dts_files" > /dev/null 2>&1
  [ $? != 0 ] && echo "Decompile $dtbo_files failed!" && exit 1
done
echo "output: $dtbodir"
chmod 777 -R $dtbodir
