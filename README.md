# android-linux-tools

Collection of scripts to help with Android ROM stuff

## Setup:

```
./setup.sh
```

## How to use

```
# Most partition image extract and system.img generate: 
## extract and generate partly imges 
makeimg.sh unpackimg.sh
### support image fromat
ext2/4 erofs squashfs sparse

## boot.img/vendor_boot.img
makeboot.sh unpackboot.sh  

## xxx dat/br generate:
img2sdat.sh

## android apex extract:
apex.sh

## local deodex: 
bin/oat2dex/deodex.sh

ozip extract:
oppo_ozip
# dtbo.img exgenerate:
makedtbo.sh unpackdtbo.sh

## apksign：
bin/tools/signapk/signapk.sh  

## LG kdz extract: 
unpack_kdz.sh

## oppo/oneplus ops extract:
unpack_ops.sh
```

## Clean workspace:

```
clean.sh
```

## Credits:

[LineageOS script](https://github.com/LineageOS/scripts)
[Erfan GSIs](https://github.com/erfanoabdi/ErfanGSIs)  
[MToolkit](https://github.com/Nightmare-MY)  
[AndroidDump](https://github.com/AndroidDump/dumper)  
[erofsUnpack](https://github.com/thka2016/erofsUnpack)  
[oppo_ozip_decrypt](https://github.com/bkerler/oppo_ozip_decrypt)
