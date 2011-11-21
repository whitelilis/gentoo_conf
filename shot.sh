#!/bin/sh
scrot -s '%F_%T_$wx$h.png' -e 'mv $f ~/shots/'
