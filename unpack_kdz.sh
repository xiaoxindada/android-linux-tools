#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh

Usage() {
cat <<EOT
Usage:
$0 <Kdz File Path> <Out Dir>
EOT
}

if [ $# -le 1 ];then
  Usage
  exit 1
fi

kdztooldir="kdz/kdztools"
kdz_extract="$kdztooldir/unkdz.py"
dz_extract="$kdztooldir/undz.py"

kdzfile="$1"
outdir="$2"
[ -z "$outdir" ] && outdir="out"

rm -rf $outdir
mkdir -p $outdir

if [ -e $kdzfile ]; then
  echo "Exeract $kdzfile ..."
  dz_file_dir="$LOCALDIR/dzfiles"
  rm -rf $dz_file_dir
  mkdir -p $dz_file_dir 
  ls $kdz_extract
  python3 "${kdz_extract}" -f "${kdzfile}" -x -o "${dz_file_dir}" 2>/dev/null
  
  dzfile=$(ls ${dz_file_dir} | grep .dz$)
  python3 "${dz_extract}" -f "${dz_file_dir}/${dzfile}" -s -o "${outdir}" #2>/dev/null
  
  if [ $? = "0" ];then
    rm -rf $dz_file_dir
    find "${outdir}" -maxdepth 1 -type f -name "*.image" | while read -r i; do mv "${i}" "${i/.image/.img}" 2>/dev/null; done
    find "${outdir}" -maxdepth 1 -type f -name "*_a.img" | while read -r i; do mv "${i}" "${i/_a.img/.img}" 2>/dev/null; done
    echo "Extract success, output: $OUTDIR"
    chmod 777 -R $OUTDIR
  else
    echo ""
    rm -rf $outdir
    rm -rf $dz_file_dir  
  fi
else
  echo "file not found!"
  exit  1
fi

