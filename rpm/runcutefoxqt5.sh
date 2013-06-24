#!/bin/sh

export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
/usr/bin/qmlMozEmbedTestQt5 -fullscreen -url about:license

