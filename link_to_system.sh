#!/bin/sh

TARGET_DIR=$1
if [ "$TARGET_DIR" = "" ]; then
  echo "TARGET_DIR ex: /usr/bin"
  TARGET_DIR=/usr/bin
fi

OBJDIR="obj--dir"

if [ -f $(pwd)/objdir-name ]; then
  OBJDIR=`cat $(pwd)/objdir-name`;
  echo "objdir-stamp detected: $OBJDIR"
fi

mkdir -p $TARGET_DIR

FILES_LIST="
$OBJDIR/qmlMozEmbedTest
"
for str in $FILES_LIST; do
    fname="${str##*/}"
    rm -f $TARGET_DIR/$fname;
    ln -s $(pwd)/$str $TARGET_DIR/$fname;
done
