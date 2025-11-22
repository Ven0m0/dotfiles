#! /usr/bin/bash
# vim: set filetype=bash:

# opt-png: Recompresses .png files

# Copyright (C) 2004-2021 by Brian Lindholm.  This file is part of the
# littleutils utility set.
#
# The opt-png utility is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later version.
#
# The opt-png utility is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# the littleutils.  If not, see <https://www.gnu.org/licenses/>.

# get command-line options
declare -i DPI=0
declare -i DPM=0
GRAY='n'
TOUCH='n'
VERBOSE='y'
while getopts ghqr:t opts ; do
  case $opts in
    g) GRAY='y' ;;
    h) echo 'opt-png 1.2.7'
       echo 'usage: opt-png [-g(ray)] [-h(elp)] [-q(uiet)] [-t(ouch)] PNG_filename ...'
       exit 0 ;;
    q) VERBOSE='n' ;;
    r) DPI=$OPTARG ;;
    t) TOUCH='y' ;;
    *) echo 'opt-png 1.2.7'
       echo 'usage: opt-png [-g(ray)] [-h(elp)] [-q(uiet)] [-t(ouch)] PNG_filename ...'
       exit 1 ;;
  esac
done
shift $((${OPTIND}-1))
if [ $DPI -gt 0 ]; then
  DPM=$((${DPI}*10000/254))
fi

# set up traps
trap 'rm -f $TMPPNG0 $TMPPNG1 $TMPPNG2A $TMPPNG2 ; exit 1' 1 2 3 13 15

# run through files
declare -i RC=0 S0=0 S1=0 S2=0
while [ $# -gt 0 ]; do

  # make sure we can read and modify file
  if [ ! -f "$1" -o ! -r "$1" -o ! -w "$1" ]; then
    echo "opt-png warning: $1 is not a writeable non-directory file"
    shift; continue
  fi

  # are we forcing to grayscale?
  if [ "$GRAY" = 'y' ]; then
    imagsize "$1" | grep -F -v -q 'png-gray'
    if [ $? -eq 1 ]; then
      FORCE=n
    else
      FORCE=y
    fi
  else
    FORCE=n
  fi

  # strip out extraneous information
  TMPPNG0=$(tempname -s .png opt-png_$$_0) || exit 99
  if [ $DPM -gt 0 ]; then
    if [ "$FORCE" = 'y' ]; then
      pngstrip -r $DPM -g "$1" $TMPPNG0
    else
      pngstrip -r $DPM "$1" $TMPPNG0
    fi
  else
    if [ "$FORCE" = 'y' ]; then
      pngstrip -g "$1" $TMPPNG0
    else
      pngstrip "$1" $TMPPNG0
    fi
  fi
  if [ $? -ne 0 ]; then
    echo "opt-png error: $1 is a bad png file: pngstrip rc = $?"
    rm -f $TMPPNG0
    shift; continue
  fi

  # optimally recompress
  TMPPNG1=$(tempname -s .png opt-png_$$_1) || exit 99
  if [ $DPI -gt 0 ]; then
    pngcrush -brute -l 9 -res $DPI -s $TMPPNG0 $TMPPNG1
  else
    pngcrush -brute -l 9 -s $TMPPNG0 $TMPPNG1
  fi
  if [ $? -ne 0 ]; then
    echo "opt-png error: $1 is a bad png file: pngcrush rc = $?"
    rm -f $TMPPNG0 $TMPPNG1
    shift; continue
  fi

  # if not a grayscape PNG file, attempt to color-reduce
  imagsize $TMPPNG0 | grep -F -v -q 'png-gray'
  if [ $? -eq 1 ]; then
    RC=1
  else
    TMPPNG2A=$(tempname -s .png opt-png_$$_2a) || exit 99
    pngrecolor -q $TMPPNG0 $TMPPNG2A
    RC=$?
  fi

  # if successful on color-reduction
  if [ $RC -eq 0 ]; then

    # optimally recompress color-reduced image
    TMPPNG2=$(tempname -s .png opt-png_$$_2) || exit 99
    if [ $DPI -gt 0 ]; then
      pngcrush -brute -l 9 -res "$DPI" -s $TMPPNG2A $TMPPNG2
    else
      pngcrush -brute -l 9 -s $TMPPNG2A $TMPPNG2
    fi
    if [ $? -ne 0 ]; then
      echo "opt-png error: bizzare result on $1: pngcrush rc = $?"
      rm -f $TMPPNG0 $TMPPNG1 $TMPPNG2A $TMPPNG2
      shift; continue
    fi

    # ensure that new file is smaller
    if [ "$TOUCH" = 'y' ]; then
      touch -r "$1" $TMPPNG1 $TMPPNG2
    fi
    S0=$(filesize "$1")
    S1=$(filesize $TMPPNG1)
    S2=$(filesize $TMPPNG2)
    if [ $S2 -lt $S1 ]; then
      if [ "$FORCE" = 'y' -o $S2 -lt $S0 ]; then
        cp --preserve=timestamps $TMPPNG2 "$1"
        if [ "$VERBOSE" = 'y' ]; then
          echo "$1: $S0 vs. $S2"
        fi
      else
        if [ "$VERBOSE" = 'y' ]; then
          echo "$1: unchanged"
        fi
      fi
    else
      if [ "$FORCE" = 'y' -o $S1 -lt $S0 ]; then
        cp --preserve=timestamps $TMPPNG1 "$1"
        if [ "$VERBOSE" = 'y' ]; then
          echo "$1: $S0 vs. $S1"
        fi
      else
        if [ "$VERBOSE" = 'y' ]; then
          echo "$1: unchanged"
        fi
      fi
    fi

  # if color-reduction not successful or skipped
  else

    if [ "$TOUCH" = 'y' ]; then
      touch -r "$1" $TMPPNG1
    fi
    S0=$(filesize "$1")
    S1=$(filesize $TMPPNG1)
    if [ "$FORCE" = 'y' -o $S1 -lt $S0 ]; then
      cp --preserve=timestamps $TMPPNG1 "$1"
      if [ "$VERBOSE" = 'y' ]; then
        echo "$1: $S0 vs. $S1"
      fi
    else
      if [ "$VERBOSE" = 'y' ]; then
        echo "$1: unchanged"
      fi
    fi

  fi

  # clean up afterwards
  rm -f $TMPPNG0 $TMPPNG1 $TMPPNG2A $TMPPNG2
  shift

done
