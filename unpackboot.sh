#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR
source ./bin.sh

bb="$bin/busybox"
toolsdir="$LOCALDIR/boot_tools"
cpio="$toolsdir/cpio"
lz4="$toolsdir/lz4"
aik="$toolsdir/AIK"
image_type="$1"
final_outdir="$LOCALDIR/${image_type}_out"
image="${image_type}.img"

usage() {
  cat <<EOF
$0 <image_type>
  image_type: boot or vendor_boot
EOF
  exit 1
}

abort() {
  echo -e $*
  exit 1
}

extract_ramdisk() {
  local ramdisk_dir="${image_type}_ramdisk"
  local comp=$($toolsdir/magiskboot decompress ramdisk.cpio 2>&1 | sed -n 's;.*\[\(.*\)\];\1;p')
  local compext=".${comp}"

  echo "$comp" >ramdisk_comp

  rm -rf $ramdisk_dir
  mkdir -p $ramdisk_dir

  case $comp in
  gzip) compext=".gz" ;;
  lzop) compext=".lzo" ;;
  xz) ;;
  lzma) ;;
  bzip2) compext=".bz2" ;;
  lz4) compext=".lz4" ;;
  lz4_legacy) compext=".lz4" ;;
  raw) compext="" ;;
  *)
    echo "Unsupport ramdisk compressed type!"
    return 1
    ;;
  esac

  if [ -n "$compext" ]; then
    mv -f ramdisk.cpio ramdisk.cpio$compext
    $toolsdir/magiskboot decompress ramdisk.cpio$compext ramdisk.cpio
    if [ $? != 0 ]; then
      echo "ramdisk decompress failed!"
      return 1
    fi
    mv -f ramdisk.cpio$compext .ramdisk.cpio$compext.orig
  fi

  cd $ramdisk_dir
  $toolsdir/magiskboot cpio "../ramdisk.cpio" extract >/dev/null 2>&1
  if [ $? != 0 ]; then
    echo "ramdisk extract failed!"
    return 1
  fi
  [ -z "$compext" ] && mv -f ../ramdisk.cpio ../ramdisk.cpio.orig

  return 0
}

extract_with_aik() {
  cd $LOCALDIR
  rm -rf $final_outdir
  mkdir -p $final_outdir
  cp -frp $image $aik/
  cd $aik
  sudo ./unpackimg.sh $image
  if [ $? = "0" ]; then
    rm -rf $image
    mv -f ramdisk/ $final_outdir/
    mv -f split_img/ $final_outdir/
    echo "aik" >$final_outdir/extract_prog
    echo "output: $final_outdir"
  else
    echo "first scheme failed!"
    rm -rf $image
    ./cleanup.sh
    return 1
  fi

  return 0
}

extract_with_magiskboot() {
  cd $LOCALDIR
  rm -rf $final_outdir
  mkdir -p $final_outdir
  cp -frp $toolsdir/magiskboot $final_outdir/
  cp -frp $image $final_outdir/
  cd $final_outdir

  ./magiskboot unpack -h $image
  if [ $? = "0" ]; then
    rm -rf $image magiskboot
    if [ -f ramdisk.cpio ]; then
      echo "extract ramdisk ..."
      extract_ramdisk
      [ $? != 0 ] && return 1
    fi
    cd $final_outdir # 因为 magiskboot 提取 ramdisk 的原因, 必须二次cd一次否则会目录错误
    echo "magiskboot" >$final_outdir/extract_prog
    echo "output: $final_outdir"
  else
    rm -rf $final_outdir
    return 1
  fi

  cd $LOCALDIR
  return 0
}

[ $# != 1 ] && usage
[ ! -f $LOCALDIR/$image ] && abort "$LOCALDIR/$image not found!"

extract_with_magiskboot
if [ $? != 0 ]; then
  echo "First scheme failed!"
  echo "Start trying the second scheme..."
  extract_with_aik
  [ $? != 0 ] && abort "Second scheme failed!"
fi
chmod 777 -R $final_outdir
