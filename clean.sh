LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR

for i in $(ls $LOCALDIR); do
  [ ! -d $LOCALDIR/$i ] && continue
  if [ -f $LOCALDIR/$i/clean.sh ]; then
    $LOCALDIR/$i/clean.sh
  fi
done

rm -rf *.pyc *.bin *.img *.zip
