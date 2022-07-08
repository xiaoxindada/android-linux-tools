#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

lpunpack="build_super/lpunpack"

rm -rf ./super
mkdir ./super

[ ! -e ./super.img ] && echo "super.img not found!" && exit 1

if file ./super.img | grep -qo 'sparse'; then
  echo "Current super.img converting rimg ..."
  $bin/simg2img ./super.img ./superr.img
  echo "success"
  super_size=$(du -sb "./superr.img" | awk '{print $1}' | bc -q)
  echo "Current super.img size: $super_size bytes"
  echo "ertract super.img..."
  $lpunpack ./superr.img ./super
  if [ $? != "0" ]; then
    rm -rf ./superr.img
    echo "extract failed!"
    exit 1
  else
    echo "extract success"
  fi
  rm -rf ./superr.img
  chmod 777 -R ./super
fi

if [ $(grep -o 'data' ./file.txt) ]; then
  super_size=$(du -sb "./super.img" | awk '{print $1}' | bc -q)
  echo "Current super.img size: $super_size bytes"
  echo "ertract super.img..."
  $lpunpack ./super.img ./super
  if [ $? != "0" ]; then
    echo "extract failed!"
    exit
  else
    echo "extract success"
  fi
  chmod 777 -R ./super
fi
