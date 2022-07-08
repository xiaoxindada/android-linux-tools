#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh

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
  "-h"|"--help")
    Usage
    exit 1
    ;;   
esac

if [ "$1" = "" ];then
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
  echo "Converting simg..."
  $bin/img2simg "$rimg_file" "$simg_file"
  if [ $? != "0" ];then
    echo "Convert failed!"
  else
    echo "Convert success"
    mv -f $simg_file $bin/img2sdat/${image_name}.img
  fi
}

function simg2sdat() {
  if [ ! -f $bin/img2sdat/${image_name}.img ];then
    cp -frp $image $bin/img2sdat/${image_name}.img
  fi
  cd $bin/img2sdat
  rm -rf ./output
  mkdir ./output
  file ${image_name}.img
  echo "Create ${image_name}.new.dat..."
  python3 ./img2sdat.py "${image_name}.img" -o "output" -v "4" -p "$image_name"
  if [ $? != "0" ];then
    echo "Convert failed!"
    rm -rf ${image_name}.img
    exit 1
  else
    echo "${image_name}.new.dat create success"
    rm -rf ${image_name}.img
    cd $LOCALDIR
    rm -rf ./new_dat
    mkdir ./new_dat
    mv $bin/img2sdat/output/* ./new_dat/
    echo "output: $LOCALDIR/new_dat"
  fi
}

function sdat2sdat_br() {
  echo "Create ${image_name}.new.dat.br..."
  $bin/brotli -q 0 $LOCALDIR/new_dat/${image_name}.new.dat -o $LOCALDIR/new_dat/${image_name}.new.dat.br
  if [ $? != "0" ] ;then 
    echo "${image_name}.new.dat.br Convert failed!"
    exit
   else
    echo "${image_name}.new.dat.br create success"
    echo "outpt: $LOCALDIR/new_dat/${image_name}.new.dat.br"
  fi
}

if ! (file $image | grep -qo "sparse") ;then
  img2simg
fi

simg2sdat

if [ "$2" = "--make_br" ];then
  make_br="true"
fi

if [ $make_br = "true" ];then
  sdat2sdat_br
fi
