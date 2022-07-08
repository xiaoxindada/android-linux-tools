#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

toolsdir="$LOCALDIR/oppo_decrypt"
ops_extract_tool="$toolsdir/opscrypto.py"
ops_input_dir="$toolsdir/extract"
ops_file="$1"

if [ -d $LOCALDIR/ops_out ]; then
  rm -rf $toolsdir/extract
  mv $LOCALDIR/ops_out $toolsdir/extract
fi
cd $toolsdir
echo "Repack ops ..."
rm -rf out.ops md5sum_pack.md5
python3 "${ops_extract_tool}" encrypt "${toolsdir}/extract"
if [ -s out.ops ];then
  mkdir -p repack_ops
  mv md5sum_pack.md5 repack_ops/
  mv out.ops repack_ops/
  chmod -R 777 repack_ops/
  mv repack_ops/ $LOCALDIR
  exit 0
else
  echo "repack ops failed!"
  exit 1
 fi
