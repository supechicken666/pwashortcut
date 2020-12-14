#!/bin/bash
CREW_PREFIX=$2
appname=$3
icon=$1
path=$CREW_PREFIX/share/pixmaps
icon () { ls -1 $path 2> /dev/null | grep $icon; }
num=`icon | wc -l`
if [[ "$num" != "1" ]]
then
echo "$num icons were found for $appname"
icon
read -r -p "Which icon you want to use?" appname_response
iconpath=$path/$appname_response
else
iconpath=$path/`icon`
fi
if [[ $iconpath = *.xpm ]]
then
convert $iconpath ${iconpath}.png
echo ${iconpath}.png
else
echo $iconpath
fi