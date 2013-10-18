#!/bin/bash
base_dir=$(cd $(dirname $0); pwd)
echo $base_dir
echo $HOME

cd $base_dir
for f in _*
do
	ln -svf $base_dir/$f $HOME/$(echo $f | sed 's/^_/./')
done

