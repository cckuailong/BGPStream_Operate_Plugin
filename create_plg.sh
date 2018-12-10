#!/bin/bash

write_file(){
pos=`awk "/$1/{print NR}" "$3"`
sed -i "$pos i $2" "$3"
}

# upper the name
up=$(echo $1 | tr '[a-z]' '[A-Z]')

# edit configure.ac
file='configure.ac'
balance='this MUST go after all the ED_WITH_PLUGIN macro calls'
txt="ED_WITH_PLUGIN([bgpcorsaro_$1],[$1],[$up],[yes])"
write_file "$balance" "$txt" "$file"

# edit bgpcorsaro/lib/bgpcorsaro_plugin.h
file='bgpcorsaro/lib/bgpcorsaro_plugin.h'
tmp=$file'_tmp'
num=`sed -n '/^typedef enum bgpcorsaro_plugin_id {/,/^} bgpcorsaro_plugin_id_t;/p' $file | grep 'BGPCORSARO_PLUGIN_ID' | wc -l`
tmp_pos=`awk "/Maximum plugin ID assigned/{print NR}" $file`
sed "$tmp_pos,$(($tmp_pos+1))d" $file > $tmp
balance='} bgpcorsaro_plugin_id_t;'
txt="\/\*\* $up plugin \*\/\n  BGPCORSARO_PLUGIN_ID_$up = $num,\n\n  \/\*\* Maximum plugin ID assigned \*\/\n  BGPCORSARO_PLUGIN_ID_MAX = BGPCORSARO_PLUGIN_ID_$up\n"
write_file "$balance" "$txt" "$tmp"
rm -f $file
mv $tmp $file

# edit bgpcorsaro/lib/bgpcorsaro_plugin.c
file='bgpcorsaro/lib/bgpcorsaro_plugin.c'
balance="\* add new plugin includes below using:"
txt="\/\*\*\/\n#ifdef WITH_PLUGIN_$up\n#include \"bgpcorsaro_$1.h\"\n#endif\n"
pos=`awk "/$balance/{print NR}" "$file"`
pos1=$(($pos-1))
sed -i "$pos1 i $txt" "$file"

# edit bgpcorsaro/lib/plugins/Makefile.am
file='bgpcorsaro/lib/plugins/Makefile.am'
balance="# Add new plugins below here using:"
txt="if WITH_PLUGIN_$up\nPLUGIN_SRC+=bgpcorsaro_$1.c bgpcorsaro_$1.h\nendif"
pos=`awk "/$balance/{print NR}" "$file"`
pos1=$(($pos-1))
sed -i "$pos1 i $txt" "$file"

# bgpcorsaro/lib/plugins/bgpcorsaro_***.h
file="bgpcorsaro/lib/plugins/bgpcorsaro_$1.h"
cp "bgpcorsaro_template.h" "$file"
sed -i "s/template/$1/g" "$file"
sed -i "s/TEMPLATE/$up/g" "$file"

# bgpcorsaro/lib/plugins/bgpcorsaro_***.c
file="bgpcorsaro/lib/plugins/bgpcorsaro_$1.c"
cp "bgpcorsaro_template.c" "$file"
sed -i "s/template/$1/g" "$file"
sed -i "s/TEMPLATE/$up/g" "$file"

autoreconf -vfi
./configure
make
sudo make install

