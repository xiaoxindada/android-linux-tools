#!/bin/bash

# Copyright (C) 2021 Xiaoxindada <2245062854@qq.com>

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

dtc="$LOCALDIR/dtb_tools/dtc"
mkdtimg_tool="$LOCALDIR/dtb_tools/mkdtboimg.py"
dtbodir="$OUTDIR/dtbo"

rm -rf $dtbodir/new_dtbo_files
mkdir -p $dtbodir/new_dtbo_files

if [ -d $dtbodir/dtbo_files ]; then
  mv $dtbodir/dtbo_files $dtbodir/dtbo_files_old
fi

dts_files_name=$(ls $dtbodir/dts_files)
for dts_files in $dts_files_name; do
  new_dtbo_files=$(echo "$dts_files" | sed 's/dts/dtbo/g')
  echo "$dts_files to $new_dtbo_files"
  $dtc -@ -I "dts" -O "dtb" "$dtbodir/dts_files/$dts_files" -o "$dtbodir/new_dtbo_files/$new_dtbo_files" >/dev/null 2>&1
done

file_number=$(ls -l $dtbodir/new_dtbo_files | grep "^-" | wc -l)
echo "Current dtbo files number is: $file_number "
echo "Create dtbo.img..."
$mkdtimg_tool create "$dtbodir/dtbo_new.img" --page_size="4096" $dtbodir/new_dtbo_files/*
if [ $? = 0 ]; then
  echo "dtbo.img output: $dtbodir/dtbo_new.img"
  chmod 777 -R $dtbodir
else
  echo "dtbo.img create failed!"
fi
