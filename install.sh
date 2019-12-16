# install.sh

# bash install.sh [-s|-u]
# option : -s taget directorys are /usr/local/bin and /usr/local/share/ltxtools (default when root)
#          -u taget directorys are $HOME/bin and $HOME/share/ltxtools (default when user mode)


if [[ $# -eq 1 && $1 == "-u" ]] ; then
  bin="$HOME/bin"
  share="$HOME/share"
elif [[ $# -eq 1 && $1 == "-s" ]] ; then
  # root privilege is needed to install.
  bin="/usr/local/bin"
  share="/usr/local/share"
elif [[ $# -eq 0 ]] ; then
  if [[ -w /usr/local/bin ]] ; then
    bin="/usr/local/bin"
    share="/usr/local/share"
  else
    bin="$HOME/bin"
    share="$HOME/share"
  fi
else
  # argument error, print usage to stderr
  echo "Usage : bash install.sh [-s|-u]" 1>&2
  exit 1
fi

ltxtools="$share/ltxtools"
me=$(whoami)

bcopy() {
cp $1.$2 $bin/$1
chown ${me}:${me} $bin/$1
chmod 755 $bin/$1
}

tcopy() {
  cp -u $1 $ltxtools/$1
  chown ${me}:${me} $ltxtools/$1
  chmod 644 $ltxtools/$1
}

if [[ ! (-a $bin) ]] ; then
  mkdir $bin
elif [[ ! (-d $bin) ]] ; then
  echo "There is bin file but not directory at ${bin}." 1>&2
  exit 1
fi
if [[ ! (-a $share) ]] ; then
  mkdir $share
elif [[ ! (-d $share) ]] ; then
  echo "There is share file but not directory at ${share}." 1>&2
  exit 1
fi

# generate bin scripts
bcopy insertcode rb
bcopy reset rb
bcopy indent rb
bcopy cattex rb
bcopy every sh
bcopy label rb
