#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh
toolsdir="$LOCALDIR/img2sdat"
dat_out_dir="$LOCALDIR/new_dats"

function Usage() {
  cat <<EOT
Usage:
$0 <Image Path> [Other args]
  Image Path: Image Path
  
  Other args:
    [--make_br]: Make new.dat.br
EOT
}

case $1 in
"-h" | "--help")
  Usage
  exit 1
  ;;
esac

if [ "$1" = "" ]; then
  Usage
  exit 1
fi

image="$1"
image_name=$(echo ${image##*/} | sed 's/\.img//')
make_br="false"

[ ! -e $image ] && echo "$image not found!" && exit 1

function img2simg() {
  rimg_file="$image"
  simg_file=$(echo "${image%%.*}" | sed 's/$/&s\.img/')
  echo "Converting to simg ..."
  $bin/img2simg "$rimg_file" "$simg_file"
  if [ $? != "0" ]; then
    echo "Convert failed!"
  else
    echo "Convert success"
    mv -f $simg_file $toolsdir/${image_name}.img
  fi
}

function simg2sdat() {
  if [ ! -f $toolsdir/${image_name}.img ]; then
    cp -frp $image $toolsdir/${image_name}.img
  fi
  cd $toolsdir
  rm -rf output
  mkdir -p output
  echo "Create ${image_name}.new.dat..."
  python3 ./img2sdat.py "${image_name}.img" -o "output" -v "4" -p "$image_name"
  if [ $? != "0" ]; then
    echo "Convert failed!"
    rm -rf ${image_name}.img
    cd $LOCALDIR
    rm -rf $toolsdir/output
    exit 1
  else
    echo "${image_name}.new.dat create success"
    rm -rf ${image_name}.img
    rm -rf $dat_out_dir
    mkdir -p $dat_out_dir
    mv output/* $dat_out_dir
    cd $LOCALDIR
    rm -rf $toolsdir/output
    echo "Output: $dat_out_dir"
  fi
}

function sdat2sdat_br() {
  while true; do
    read -p "Need to create ${image_name}.new.dat.br? (y/n): " make_br
    case $make_br in
    "y")
      echo "Create ${image_name}.new.dat.br..."
      $bin/brotli -q 0 $dat_out_dir/${image_name}.new.dat -o $dat_out_dir/${image_name}.new.dat.br
      if [ $? != "0" ]; then
        echo "${image_name}.new.dat.br Convert failed!"
        exit 1
      else
        echo "${image_name}.new.dat.br create success"
        echo "outpt: $dat_out_dir/${image_name}.new.dat.br"
      fi
      break
      ;;
    "n") break ;;
    *) echo "Invalid input!" ;;
    esac
  done
}

if ! (file $image | grep -qo "sparse"); then
  img2simg
fi
simg2sdat
sdat2sdat_br
