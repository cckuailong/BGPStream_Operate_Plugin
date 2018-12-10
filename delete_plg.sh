#!/bin/bash

# upper the name
up=$(echo $1 | tr '[a-z]' '[A-Z]')

# Edit configure.ac
file="configure.ac"
tmp=$file'_tmp'
balance="ED_WITH_PLUGIN\(\[bgpcorsaro_$1\],\[$1\],\[$up\],\[yes\]\)"
pos=`awk "/$balance/{print NR}" "$file"`
if [ ! -n "$pos" ]; then
    echo "There is no such plugin which names $1"
    exit 1
fi
sed "$pos d" $file > $tmp
rm -f $file
mv $tmp $file

# Edit bgpcorsaro/lib/bgpcorsaro_plugin.h
file='bgpcorsaro/lib/bgpcorsaro_plugin.h'
tmp=$file'_tmp'
balance="BGPCORSARO_PLUGIN_ID_$up ="
pos=`awk "/$balance/{print NR}" "$file"`
if [ ! -n "$pos" ]; then
    echo "There is no such plugin which names $1"
    exit 1
fi
pos1=$(($pos-3))
new_txt=`sed -n "$pos1, 1p" $file | awk '{print $1}'`
sed -i "s/= BGPCORSARO_PLUGIN_ID_$up/= $new_txt/g" $file
sed "$(($pos-2)),$pos d" $file > $tmp
rm -f $file
mv $tmp $file

# bgpcorsaro/lib/bgpcorsaro_plugin.c
file="bgpcorsaro/lib/bgpcorsaro_plugin.c"
balance="#ifdef WITH_PLUGIN_$up"
tmp=$file'_tmp'
pos=`awk "/$balance/{print NR}" "$file"`
if [ ! -n "$pos" ]; then
    echo "There is no such plugin which names $1"
    exit 1
fi
pos_start=$(($pos-1))
pos_end=$(($pos+3))
sed "$pos_start,$pos_end d" $file > $tmp
rm -f $file
mv $tmp $file

# Edit bgpcorsaro/lib/plugins/Makefile.am
file="bgpcorsaro/lib/plugins/Makefile.am"
balance="if WITH_PLUGIN_$up"
tmp=$file'_tmp'
pos=`awk "/$balance/{print NR}" "$file"`
if [ ! -n "$pos" ]; then
    echo "There is no such plugin which names $1"
    exit 1
fi
pos_end=$(($pos+2))
sed "$pos,$pos_end d" $file > $tmp
rm -f $file
mv $tmp $file

rm -f "bgpcorsaro/lib/plugins/bgpcorsaro_$1.h"
rm -f "bgpcorsaro/lib/plugins/bgpcorsaro_$1.c"

autoreconf -vfi
./configure
make
sudo make install
