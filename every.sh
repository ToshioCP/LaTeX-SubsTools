#!/bin/bash

if [[ $# -eq 1 ]]; then
  rootfile=main.tex
elif [[ $# -eq 2 ]]; then
  rootfile=$(basename $2 | sed 's/.tex$//' ).tex
else
  echo "Usage: every script [rootfile]" 1>&2
fi
script="$1"

if [[ ! -f $rootfile ]]; then
  echo "No such LaTeX main file : $dname/$rootfile" 1>&2
  exit 1
fi

for file in $(tfiles -a $rootfile) ; do
  $script $file
done
