# uninstall.sh

# bash uninstall.sh [-s|-u]
# option : -s taget directorys are /usr/local/bin and /usr/local/share/ltxtools (default when root)
#          -u taget directorys are $HOME/bin and $HOME/share/ltxtools (default when user mode)

binfiles="cattex every indent insertcode label revert"

if [[ $# -eq 1 && $1 == "-u" ]] ; then
  bin="$HOME/bin"
elif [[ $# -eq 1 && $1 == "-s" ]] ; then
  # root privilege is needed to install.
  bin="/usr/local/bin"
elif [[ $# -eq 0 ]] ; then
  if [[ -w /usr/local/bin ]] ; then
    bin="/usr/local/bin"
  else
    bin="$HOME/bin"
  fi
else
  # argument error, print usage to stderr
  echo "Usage : bash uninstall.sh [-s|-u]" 1>&2
  exit 1
fi

for file in $binfiles ; do
  if [[ -f $bin/$file ]] ; then
    rm $bin/$file
  fi
done

