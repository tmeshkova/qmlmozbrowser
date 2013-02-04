#!/bin/sh

TARGET_DIR=/usr/bin
mkdir -p $TARGET_DIR

FILES_LIST="
release/qmlMozEmbedTest
"
for str in $FILES_LIST; do
    fname="${str##*/}"
    rm -f $TARGET_DIR/$fname;
    ln -s $(pwd)/$str $TARGET_DIR/$fname;
done
